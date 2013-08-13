require 'httparty'
require 'cgi' unless defined?(CGI) && defined?(CGI::escape)

module Namecheap
  class Client
    include HTTParty
    base_uri 'https://api.sandbox.namecheap.com/xml.response'

    class NamecheapApiException < StandardError
    end

    def initialize(api_username, api_key, api_url=nil)
      @auth = { :api_username => api_username, :api_key => api_key }
      self.class.base_uri(api_url) if api_url
    end

    def get_domains
      result = api_call('namecheap.domains.getList', {})
      hash = result.parsed_response['ApiResponse']['CommandResponse']['DomainGetListResult'] || {}
      hash['Domain'] || []
    end

    def purchase_domain(domain_name, years, contact_hash)
      h = {
        :DomainName => domain_name,
        :Years => years,
        :RegistrantFirstName => contact_hash[:first_name],
        :RegistrantLastName => contact_hash[:last_name],
        :RegistrantAddress1 => contact_hash[:address1],
        :RegistrantAddress2 => contact_hash[:address2],
        :RegistrantCity => contact_hash[:city],
        :RegistrantStateProvince => contact_hash[:state],
        :RegistrantPostalCode => contact_hash[:postal_code],
        :RegistrantCountry => contact_hash[:country],
        :RegistrantPhone => contact_hash[:phone],
        :RegistrantEmailAddress => contact_hash[:email],
        :TechFirstName => contact_hash[:first_name],
        :TechLastName => contact_hash[:last_name],
        :TechAddress1 => contact_hash[:address1],
        :TechAddress2 => contact_hash[:address2],
        :TechCity => contact_hash[:city],
        :TechStateProvince => contact_hash[:state],
        :TechPostalCode => contact_hash[:postal_code],
        :TechCountry => contact_hash[:country],
        :TechPhone => contact_hash[:phone],
        :TechEmailAddress => contact_hash[:email],
        :AdminFirstName => contact_hash[:first_name],
        :AdminLastName => contact_hash[:last_name],
        :AdminAddress1 => contact_hash[:address1],
        :AdminAddress2 => contact_hash[:address2],
        :AdminCity => contact_hash[:city],
        :AdminStateProvince => contact_hash[:state],
        :AdminPostalCode => contact_hash[:postal_code],
        :AdminCountry => contact_hash[:country],
        :AdminPhone => contact_hash[:phone],
        :AdminEmailAddress => contact_hash[:email],
        :AuxBillingFirstName => contact_hash[:first_name],
        :AuxBillingLastName => contact_hash[:last_name],
        :AuxBillingAddress1 => contact_hash[:address1],
        :AuxBillingAddress2 => contact_hash[:address2],
        :AuxBillingCity => contact_hash[:city],
        :AuxBillingStateProvince => contact_hash[:state],
        :AuxBillingPostalCode => contact_hash[:postal_code],
        :AuxBillingCountry => contact_hash[:country],
        :AuxBillingPhone => contact_hash[:phone],
        :AuxBillingEmailAddress => contact_hash[:email],
      }
      if domain_name.end_with?('.us')
        h[:RegistrantNexus] = 'C21'
        h[:RegistrantPurpose] = 'P1'
      end
      result = api_call('namecheap.domains.create', h)
    end

    def configure_dns_records(domain_name, dns_array)
      domain_parts = domain_name.split(".")
      hash = {
        :SLD => domain_parts[0], # mywebsite
        :TLD => domain_parts[1], # com
      }
      dns_array.each_with_index{|config,i|
        hash["HostName#{i+1}"] = config[:host_name]
        hash["RecordType#{i+1}"] = config[:type]
        hash["Address#{i+1}"] = config[:value]
      }
      result = api_call('namecheap.domains.dns.setHosts', hash)
      result.parsed_response['ApiResponse']['Errors'].nil?
    end

    def configure_email_forwarding(domain_name, email_array)
      hash = {:DomainName => domain_name}
      email_array.each_with_index{|config,i|
        hash["MailBox#{i+1}"] = config[:username]
        hash["ForwardTo#{i+1}"] = config[:forward_to]
      }
      result = api_call('namecheap.domains.dns.setEmailForwarding', hash)
      result.parsed_response['ApiResponse']['Errors'].nil?
    end

    def domain_available?(domain_name_or_array)
      list = domain_name_or_array.is_a?(String) ? domain_name_or_array : domain_name_or_array.join(",")
      result = api_call('namecheap.domains.check', {:DomainList => list})
      domains = {}
      if domain_name_or_array.is_a?(String)
        result = result.parsed_response['ApiResponse']['CommandResponse']['DomainCheckResult']
        domains[result['Domain']] = (result['Available']=='true')
      else
        result.parsed_response['ApiResponse']['CommandResponse']['DomainCheckResult'].each{|h| domains[h['Domain']] = (h['Available']=='true')}
      end
      domains
    end

    private
    def api_call(method_name, parameters)
      query = "?" + to_param(compile_args(parameters.merge :Command => method_name))
      result = self.class.get(query)
      if result.parsed_response['ApiResponse']['Errors'] && result.parsed_response['ApiResponse']['Errors'].count > 0
        err = result.parsed_response['ApiResponse']['Errors'].first[1]
        raise NamecheapApiException, "Namecheap API Error: code=#{err['Number']} msg=#{err['__content__']}"
      end
      result
    end

    def compile_args(args = {})
      final = {}
      final['ApiUser'] = @auth[:api_username]
      final['UserName'] = @auth[:api_username]
      final['ApiKey'] = @auth[:api_key]
      final['ClientIp'] = '127.0.0.1'
      final.merge(args)
    end

    def to_param(hash)
      hash.to_a.map{|arr| "#{CGI.escape(arr[0].to_s)}=#{CGI.escape(arr[1].to_s)}"}.join("&")
    end
  end
end