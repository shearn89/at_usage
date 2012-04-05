require 'aggregate'
require 'estimation_helpers'
require 'pgresult_extend'
class MachinesController < ApplicationController
  helper_method :sort_column, :sort_direction
  respond_to :html, :xml, :json, :js
  caches_action :spark_data, :expires_in => 15.minutes
  
  rescue_from Exception do |exception|
    render_error(exception)
  end
  rescue_from ActiveRecord::RecordNotFound do |message|
    render_not_found(message)
  end

  $query = "SELECT round_time(logtime) AS logtime,usage
  FROM usage 
  WHERE logtime > (now() - INTERVAL '1 day')
  ORDER BY logtime ASC;"

  $query_simple_2pt = """
  SELECT DISTINCT
    u.host,
    first_value(usage) OVER w AS start_val,
    last_value(usage) OVER w AS end_val,
    first_value(logtime) OVER w AS start_time,
    last_value(logtime) OVER w AS end_time
  FROM (
    SELECT * FROM usage WHERE 
    logtime > (now() - INTERVAL '1 day')
    AND
    logtime < now()) u
  WINDOW w AS (PARTITION BY host ORDER BY logtime, usage
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
  ORDER BY host;
  """
  
  # GET /machines
  # GET /machines.json
  def index
      @inuse = Machine.all().select{ |m| not m.stale and not m.offline and not m.available }.length
      @estimates = estimation
      respond_to do |format|
        format.html
        format.xml { render :xml => @machines = Machine.search(params[:search]).order(sort_column + " " + sort_direction)}
        format.json { render :json => @machines = Machine.search(params[:search]).order(sort_column + " " + sort_direction)}
      end
  end
  
  def info
    if params[:floor] || params[:lab]
      params[:search] = "#{params[:floor]}.#{params[:lab]}"
    elsif params[:flag]
      @flag = params[:flag]
      case params[:flag]
      when 'available'
        @machines ||= Machine.search(params[:search]).order(sort_column + " " + sort_direction).select{ |m| m[:available] }
      when 'stale'
        @machines ||= Machine.search(params[:search]).order(sort_column + " " + sort_direction).select{ |m| m[:stale] }
      when 'asleep'
        @machines ||= Machine.search(params[:search]).order(sort_column + " " + sort_direction).select{ |m| m[:offline] }
      when 'all'
        @machines ||= Machine.search(params[:search]).order(sort_column + " " + sort_direction)
      end
    end
    @machines ||= Machine.search(params[:search]).order(sort_column + " " + sort_direction)
    respond_with(@machines)
  end
  
  def list
    @machines = Machine.where("name = ?", params[:query]) unless params[:query].nil?
  end

  # GET /machines/1
  # GET /machines/1.json
  def show
    @machine = Machine.find_by_id_or_name!(params[:id])
    respond_with(@machine)
  end
  
  def contact
    # params should be copied over from dispatch_email
    logger.info "error message: #{flash[:error]}"
  end
  
  def dispatch_email
      if verify_recaptcha
        key = verify_data(params)
        check = key.values().reduce{|sum,v| sum and v}
        if check
          if Notifier.send_email(params).deliver
            flash[:notice] = 'Thank you for your feedback.'
            redirect_to(machines_url)
          else
            flash[:error] = 'The email could not be sent. Please try again later.'
            redirect_to(machines_url)
          end
        else
          flash[:error] = 'Invalid fields:'
          flash[:error] << (key[:name] ? '' : '<br />Name is required.')
          flash[:error] << (key[:message] ? '' : '<br />Message is required.')
          flash[:error] << (key[:email] ? '' : '<br />Valid email address required.')
          
          flash[:name] = params[:name]
          flash[:email] = params[:email]
          flash[:message] = params[:message]
          flash[:type] = true
          flash[params[:type]] = true
          
          redirect_to(:back)
        end
      else
        flash[:error] = 'reCaptcha Failed. Please try again.'
        
        flash[:name] = params[:name]
        flash[:email] = params[:email]
        flash[:message] = params[:message]
        flash[:type] = true
        flash[params[:type]] = true
        
        redirect_to(:back)
      end
  end

  def spark_data
  	logger.info ">> spark_data called, querying database. #{Time.now()}"
    begin
      $conn = PGconn.connect('pgserver',nil,nil,nil,'database','user','password')
    rescue PGError
      logger.warn "Can't connect to database."
      send_file 'app/assets/images/sparkline_local.png', :type => 'image/png'
      return
    end
    $res = $conn.exec($query)
    values = aggregate($res).values()
    spark = Sparklines.plot(values, :type => 'smooth', :height => '60', :background_color => '#ffffff',:line_color => '#404040')
    send_data spark, :type => 'image/png'
  end
  
  def estimation
    logger.info ">> estimation called"
    Rails.cache.fetch("estimation_cache", :expires_in => 15.minutes) do
      predict
    end
  end
  
  private
  
  def verify_data(params)
    out = {}
    params[:name].empty? ? out[:name] = false : out[:name] = true
    params[:message].empty? ? out[:message] = false : out[:message] = true
    params[:email].match('\S+@\S+\.\S+').nil? ? out[:email] = false : out[:email] = true
    out
  end
  
  def estimation_private
    logger.info ">> no cached data, querying database. #{Time.now()}"
    begin
      $conn = PGconn.connect('pgserver',nil,nil,nil,'database','user','password')
    rescue PGError
      logger.warn "Can't connect to database for estimation."
      return [Time.now(),-1]
    end
  
    estimates = {}
    $res_24hr = $conn.exec($query)

    ## Do estimation
    time_hash = aggregate($res_24hr)
    $res_24hr.clear()
    [2,4].each{|d|
      estimates["d#{d}"] = delta_estimation(time_hash,d)
    }
    
    yday = floor_time(Time.now()) - 85500
    wk = floor_time(Time.now()) - 603900
    
    estimates['pred_time'] = floor_time(Time.now())+900
    # get specific values
    estimates['yesterday'] = $conn.exec(time_query(yday)).unpack()
    estimates['week'] = $conn.exec(time_query(wk)).unpack()
    
    return estimates
  end
  
  def predict
    weights = [0.65, 0.3, 0, 0.05]
    # weights = [0.513, 0.475, 0.8216, 0.0615]
    estimates = estimation_private
    if estimates[1] == -1
      return estimates
    end
    final = estimates['d2'].to_f * weights[0] + estimates['d4'].to_f * weights[1] + 
      estimates['yesterday'].to_f * weights[2] + estimates['week'].to_f * weights[3]
    File.open('log/estimation_log.log','a'){|log| log.puts "#{estimates['pred_time']}\t#{final.round}" }
    return [estimates['pred_time'],final.round]
  end
  
  def render_error(exception)
    logger.error(exception)
    @exception = exception
    render :template => "/errors/500.html.erb", :status => 500
  end

  def render_not_found(message)
    render :template => "/errors/not_found.html.erb", :status => 404
  end

  def sort_column
  	Machine.column_names.include?(params[:sort]) ? params[:sort] : "available desc, lab asc, name asc"
  end

  def sort_direction
  	if %w[name lab].include?(params[:sort])
    		%w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  	else
    		%w[asc desc].include?(params[:direction]) ? params[:direction] : ""
  	end
  end
end
