class SplashController < ApplicationController

  skip_before_filter :authenticate

  def index
    
    @tracker_gems = Hash[%w( honeybadger bugsnag errorapp_notifier exceptiontrap rollbar
                            runtimeerror_notifier sentry-raven airbrake ).map{|x| [x,gem_available?(x)]}]

    puts @tracker_gems.to_yaml
  end

  def signup
    if ENV['MAILCHIMP_SPLASH_SIGNUP_LIST_ID'].blank? or ENV['MAILCHIMP_API_KEY'].blank?

      @message = "The MAILCHIMP_API_KEY and MAILCHIMP_SPLASH_SIGNUP_LIST_ID environment variables need to be set for mailing list signup to work! If you don't want this feature, you can just remove the mailing list signup feature from app/views/splash/index.html.haml"

    else
      begin

        gb = Gibbon::API.new

        gb.lists.subscribe({
          :id => ENV['MAILCHIMP_SPLASH_SIGNUP_LIST_ID'],
          :email => {:email => params[:signup_email]},
          :double_optin => true
        })

        @message = 'Thanks for signing up!'

      rescue StandardError => e
        @error = true

        if e.message =~ /is already subscribed to list/
          @message = "You're already signed up to receive updates. Thanks for your enthusiasm!"
        else
          @message = "Oops! Looks like we ran into an error. How embarrassing. Please try again later!"
        end

      end
    end
  end


  private
  
    def gem_available?(name)
       Gem::Specification.find_by_name(name)
    rescue Gem::LoadError
       false
    rescue
       Gem.available?(name)
    end

end
