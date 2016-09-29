module AresMUSH
  module Jobs
    def self.can_access_jobs?(actor)
      return actor.has_any_role?(Global.read_config("jobs", "roles", "can_access_jobs"))
    end
    
    def self.categories
      Global.read_config("jobs", "categories")
    end
    
    def self.status_vals
      Global.read_config("jobs", "status").keys
    end
    
    def self.closed_jobs
      Job.all.select { |j| !j.is_open? }
    end
    
    def self.status_color(status)
      return "" if !status
      config = Global.read_config("jobs", "status")
      key = config.keys.find { |k| k.downcase == status.downcase }
      return "%xc" if !key
      return config[key]["color"]
    end
    
    def self.with_a_job(client, number, &block)
      job = Job.where(number: number.to_i).first
      if (!job)
        client.emit_failure t('jobs.invalid_job_number')
        return
      end
      
      yield job
    end
    
    def self.with_a_request(client, enactor, number, &block)
      job = enactor.submitted_requests.where(number: number.to_i).first
      if (!job)
        client.emit_failure t('jobs.invalid_job_number')
        return
      end
      
      yield job
    end
    
    def self.comment(job, author, message, admin_only)
      JobReply.create(:author => author, 
        :job => job,
        :admin_only => admin_only,
        :message => message)
      if (admin_only)
        notification = t('jobs.discussed_job', :name => author.name, :number => job.number, :title => job.title)
        Jobs.notify(job, notification, author, false)
      else
        notification = t('jobs.responded_to_job', :name => author.name, :number => job.number, :title => job.title)
        Jobs.notify(job, notification, author)
      end
    end
    
    def self.mark_read(job, char)
      job.readers << char
      job.save
    end
    
    def self.closed_status
      Global.read_config("jobs", "closed_status")
    end
        
    def self.create_job(category, title, description, author)
      if (!Jobs.categories.include?(category))
        Global.logger.debug "Invalid job category #{category}."
        return { :job => nil, :error => t('jobs.invalid_category', :categories => Jobs.categories.join(" ")) }
      end
      
      job = Job.create(:author => author, 
        :title => title, 
        :description => description, 
        :category => category,
        :number => Game.master.next_job_number,
        :status => Global.read_config("jobs", "default_status"))
        
      game = Game.master
      game.next_job_number = game.next_job_number + 1
      game.save
      
      message = t('jobs.announce_new_job', :number => job.number, :title => job.title, :name => author.name)
      Jobs.notify(job, message, author, false)

      return { :job => job, :error => nil }
    end
    
    def self.change_job_status(enactor, job, status, message = nil)
      if (status == Jobs.closed_status)
        status_message = t('jobs.closed_job', :name => enactor.name, :status => status)
      else
        status_message = t('jobs.changed_job_status', :name => enactor.name, :status => status)
      end
            
      message = message ? "#{message}%R%R#{status_message}" : status_message

      Jobs.comment(job, enactor, message, false)
      job.status = status
      job.save
    end
    
    def self.close_job(enactor, job, message = nil)
      Jobs.change_job_status(enactor, job, Jobs.closed_status, message)
    end
    
    def self.notify(job, message, author, notify_submitter = true)
      Global.client_monitor.logged_in_clients.each do |c|
        job.readers = [ author ]
        job.save
        
        if (Jobs.can_access_jobs?(c.char) || (notify_submitter && (c.char == job.author)))
          c.emit_ooc message
        end
      end
    end
  end
end