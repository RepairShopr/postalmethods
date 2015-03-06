module PostalMethods
  
  module GetLetterStatus
    
    def get_letter_status(id)
      raise PostalMethods::NoPreparationException unless self.prepared 

      ## get status
      opts = {:Username => self.username, :Password => self.password, :ID => id}
      
      rv = @rpc_driver.call(:get_letter_status_v2, :message=>opts).body[:get_letter_status_v2_response][:get_letter_status_v2_result]

            ws_status = rv[:result_code].to_i
      delivery_status = rv[:status].to_i
          last_update = rv[:last_update_time]
      
      if ws_status == -3000
        return [delivery_status, last_update]
      elsif API_STATUS_CODES.has_key?(ws_status)
        instance_eval("raise APIStatusCode#{ws_status.to_s.gsub(/( |\-)/,'')}Exception")
      end

    end

    def get_letter_status_multiple(ids)
      raise PostalMethods::NoPreparationException unless self.prepared

      if ids.class == Array
        ids = ids.join(",")
      end
      
      # minimal input checking - let api take care of it
      return PostalMethods::InvalidLetterIDsRange unless ids.class == String

      ## get status
      opts = {:Username => self.username, :Password => self.password, :ID => ids}
      
      rv = @rpc_driver.call(:get_letter_status_v2_multiple, :message=>opts).body[:get_letter_status_v2_multiple_response][:get_letter_status_v2_multiple_result]
      ws_status = rv[:result_code].to_i
      
      if ws_status == -3000
        return rv[:letter_statuses][:letter_status_and_desc]
      elsif API_STATUS_CODES.has_key?(ws_status)
        instance_eval("raise APIStatusCode#{ws_status.to_s.gsub(/( |\-)/,'')}Exception")
      end

    end

    def get_letter_status_range(minid, maxid)
      raise PostalMethods::NoPreparationException unless self.prepared 

      ## get status
      opts = {:Username => self.username, :Password => self.password, :MinID => minid.to_i, :MaxID => maxid.to_i}
      
      rv = @rpc_driver.call(:get_letter_status_v2_range, :message=>opts).body[:get_letter_status_v2_range_response][:get_letter_status_v2_range_result]

      ws_status = rv[:result_code].to_i
      
      if ws_status == -3000
        return rv[:letter_statuses][:letter_status_and_desc]
      elsif API_STATUS_CODES.has_key?(ws_status)
        instance_eval("raise APIStatusCode#{ws_status.to_s.gsub(/( |\-)/,'')}Exception")
      end

    end
    
  end
end
