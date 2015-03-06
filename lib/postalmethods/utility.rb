module PostalMethods
  
  module UtilityMethods
    
    require 'base64'
   
    def get_letter_details(id)
      raise PostalMethods::NoPreparationException unless self.prepared 
      
      ## get a letter as pdf over the wire
      rv = @rpc_driver.call(:get_letter_details_v2, :message=>{:Username => self.username, :Password => self.password, :ID => id})
      rv = rv.body[:get_letter_details_v2_response]
      status_code = rv[:get_letter_details_v2_result][:result_code].to_i
      letter_data = rv[:get_letter_details_v2_result]
        work_mode = letter_data[:work_mode].to_s
            
      if status_code == -3000 # successfully received the req
        return [letter_data, status_code, work_mode]
      elsif API_STATUS_CODES.has_key?(status_code)
        instance_eval("raise APIStatusCode#{status_code.to_s.gsub(/( |\-)/,'')}Exception")
      end
      raise PostalMethods::GenericCodeError
    end
    
    def get_pdf(id)
      raise PostalMethods::NoPreparationException unless self.prepared 
      
      ## get a letter as pdf over the wire
      begin
        rv = @rpc_driver.call(:get_pdf, :message=>{:Username => self.username, :Password => self.password, :ID => id})
      rescue SOAP::FaultError
        raise APIStatusCode3150Exception
      end
      result = rv.body[:get_pdf_response][:get_pdf_result]
      status_code = result[:result_code].to_i

      if status_code == -3000 # successfully received the req
        return Base64.decode64(result[:file_data]) # the data returned is base64...
      elsif API_STATUS_CODES.has_key?(status_code)
        instance_eval("raise APIStatusCode#{status_code.to_s.gsub(/( |\-)/,'')}Exception")
      end
      raise PostalMethods::GenericCodeError
    end
    
    def cancel_delivery(id)
       raise PostalMethods::NoPreparationException unless self.prepared 
       
       ## get a letter as pdf over the wire
       rv = @rpc_driver.call(:cancel_delivery, :message=> {:Username => self.username, :Password => self.password, :ID => id})
       
       status_code = rv.body[:cancel_delivery_response][:cancel_delivery_result].to_i
      
       if status_code == -3000 # successfully received the req
         return true
       elsif API_STATUS_CODES.has_key?(status_code)
         instance_eval("raise APIStatusCode#{status_code.to_s.gsub(/( |\-)/,'')}Exception")
       end
       raise PostalMethods::GenericCodeError
    end
  end
end
