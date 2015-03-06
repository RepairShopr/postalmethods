module PostalMethods
  
  module SendLetter
    
    def send_letter(doc, description, work_mode = "")
      raise PostalMethods::NoPreparationException unless self.prepared 
      ## push a letter over the api
      

      
      self.document = doc
      rv = @rpc_driver.call(:send_letter_v2, :message=>{:Username => self.username, :Password => self.password, :FileExtension => self.document[:extension], 
                              :FileBinaryData => self.document[:bytes], :MyDescription => description, :WorkMode => self.work_mode})
      
      status_code = rv.body[:send_letter_v2_response][:send_letter_v2_result].to_i
      
      if status_code > 0
        return status_code
      elsif API_STATUS_CODES.has_key?(status_code)
        instance_eval("raise APIStatusCode#{status_code.to_s.gsub(/( |\-)/,'')}Exception")
      end
    end
    
    def send_letter_with_address(doc, description, address)
      raise PostalMethods::NoPreparationException unless self.prepared 
      raise PostalMethods::AddressNotHashException unless (address.class == Hash)
      
      ## setup the document
      self.document = doc

      opts = {:Username => self.username, :Password => self.password, :FileExtension => self.document[:extension], 
                                  :FileBinaryData => self.document[:bytes], :MyDescription => description, :WorkMode => self.work_mode}
                                  
      opts.merge!(address)

      ## push a letter over the api
      status_code = @rpc_driver.call(:send_letter_and_address_v2, :message=> opts).body[:send_letter_and_address_v2_response][:send_letter_and_address_v2_result].to_i
      
      if status_code > 0
        return status_code
      elsif API_STATUS_CODES.has_key?(status_code)
        instance_eval("raise APIStatusCode#{status_code.to_s.gsub(/( |\-)/,'')}Exception")
      end
    end

  end
  
end
