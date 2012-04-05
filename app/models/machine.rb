class Machine < ActiveRecord::Base
	validates :name, :presence => true
  attr_accessible :name, :lab, :available, :offline, :last_checked, :stale
  
	def initialize
		super
		self.stale ||= false
		self.available ||= true
		self.offline ||= false
	end
	
	def self.search(search)
	  if search
	    where('name like ? or lab like ?', "#{search}%", "#{search}%")
	  else
	    scoped
	  end
	end
  
  def self.find_by_id_or_name(id_or_name)
    find :first, :conditions => ['id = ? or name like ?', "#{id_or_name}", "#{id_or_name}%"]
  end
  
  def self.find_by_id_or_name!(id_or_name)
    a = find :first, :conditions => ['id = ? or name like ?', "#{id_or_name}", "#{id_or_name}%"]
    if a.nil?
      raise ActiveRecord::RecordNotFound
    else
      return a
    end
  end
  
  def self.labs
    l = self.all().map{|m| m.lab }.to_set.reject{|m| m.nil?}.sort
    l.map{|lab| lab.split('.')}
  end
  
  def self.available
    all().select{ |m| m[:available] }.length
  end
  
  def self.asleep
    all().select{ |m| m[:offline] }.length
  end
  
  def self.stale
    all().select{ |m| m[:stale] }.length
  end
  
  def self.count
    all().length
  end
end
