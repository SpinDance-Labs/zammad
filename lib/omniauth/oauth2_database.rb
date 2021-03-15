class Oauth2Database < OmniAuth::Strategies::OAuth2
  option :name, 'oauth2'

  def initialize(app, *args, &block)

    # database lookup
    config  = Setting.get('auth_oauth2_credentials') || {}
    args[0] = config['app_id']
    args[1] = config['app_secret']
    args[2][:client_options] = args[2][:client_options].merge(config.symbolize_keys)
    super
  end

  uid { raw_info['data']['id'] }

  info do
    email = raw_info['data']['attributes']['email']
    if raw_info['included'].count > 0
      first_name = raw_info['included'][0]['attributes']['firstname']
      last_name = raw_info['included'][0]['attributes']['lastname']
      phone = raw_info['included'][0]['attributes']['phone']
      name = "#{first_name} #{last_name}"
    else
      first_name = ""
      last_name = ""
      phone = ""
      name = raw_info['data']['attributes']['email']
    end
    {
      email: email,
      first_name: first_name,
      last_name: last_name,
      phone: phone,
      name: name
    }
  end

  extra do
    {
      'raw_info' => raw_info
    }
  end

  def raw_info
    JSON.parse(access_token.get('/api/v2/storefront/account?include=default_billing_address').body)
  end


end
