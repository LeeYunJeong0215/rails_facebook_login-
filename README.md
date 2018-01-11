## 2018.01.11

#### 페이스북 로그인 페이지 만들기

1. facebooklogin_class\facebook_login\Gemfile(gem 추가)

   ```ruby
   gem 'devise'
   gem 'omniauth-facebook'
   gem 'figaro'
   ```

2. ```console
   $ bundle install
   ```

3. devise 추가

   ```console
   $ rails generate devise:install
   ```

4. facebook_login\config\routes.rb

   ```ruby
   root 'home#index'
   ```

5. ```console
   $ rails g devise User(모델명)
   ```

6. facebook_login\app\views\layouts\application.html.erb

   참고 : https://github.com/plataformatec/devise/wiki/How-To:-Add-sign_in,-sign_out,-and-sign_up-links-to-your-layout-template

   ```html
     <% if user_signed_in? %>
       <%= link_to('Logout', destroy_user_session_path, method: :delete) %>
     <% else %>
       <%= link_to('Login', new_user_session_path)  %>
     <% end %>
   ```

7. devise.rb 255번째줄 수정(https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview)

   ```ruby
   config.omniauth :facebook, ENV['facebook_app_id'], ENV['facebook_app_secret'], scope: 'email'
   ```

8. figaro(환경변수 관리 gem) https://github.com/laserlemon/figaro

   ```console
   $ bundle exec figaro install
   ```

9. application.yml (https://developers.facebook.com/)

   (https://developers.facebook.com/)에서 앱을 새로 만든 후 대시보드에 id와 secret코드를 복사

   ```ruby
   facebook_app_id: 복사한 id
   facebook_app_secret: 복사한 secret코드
   ```

10. user.rb

  ```ruby
  class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    has_many :services
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable
    		,:omniauthable, omniauth_providers: [:facebook] <= 추가
  end

  ```

11. https://developers.facebook.com/apps

    ![Alt text](C:\Users\YJ\Documents\Lightshot)

12. ```console
    $ rails g devise:controllers user(컨트롤러이름)
    ```

13. routes.rb

    참고사이트 : https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview

    ```ruby
    Rails.application.routes.draw do

      devise_for :users, 
      controllers: {아래 두 줄 추가
        omniauth_callbacks: 'users/omniauth_callbacks',
        sessions: 'users/sessions'
     }
    ```

14. ```console
    $ rails g model Service user:references provider uid access_token access_token_secret refresh_token expires_at:datetime auth:text
    ```

15. omniauth_callbacks_controller.rb

    ```ruby
    # frozen_string_literal: true

    class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
      def auth
         request.env['omniauth.auth']

      end

        # <OmniAuth::AuthHash credentials=
        # <OmniAuth::AuthHash
        # expires=true expires_at=1520821048
        # token="EAAHYiH7UtWMBAMuuTM4WyzgyxBGRp9gl9TrF0hBRoPDiBEBgLTiLeyGxPiuuBKEO0jv4mfa1Xjb53KKvZAzRSxVHKlRM1sXIgFkTSasCccU42KLUwLGxqByvNIZBjf3oc2oXZA4esZCL71259ZCtUnZA8UKSc1eAGTPEvI6ZAuNOgZDZD">
        # extra=#<OmniAuth::AuthHash raw_info=#<OmniAuth::AuthHash id="1622098987866288" name="Yun Jeong Lee">>
        # info=#<OmniAuth::AuthHash::InfoHash
        # image="http://graph.facebook.com/v2.6/1622098987866288/picture" name="Yun Jeong Lee">
        # provider="facebook"
        # uid="1622098987866288">


        #auth hash는 위에 있는 주석
        #만약에 유저가 facebook을 통해 회원가입을 한 적이 있으면?
        def facebook
          service = Service.where(provider: auth.provider, uid: auth.uid).first
          if service.present?
            #유저를 가져오면 된다
            user = service.user
            service.update( # 시간과 토큰을 계속 업데이트 해줌.
              expires_at: Time.at(auth.credentials.expires_at),
              access_token: auth.credentials.token
            )
          else
            #유저를 생성하면 된다.
            p auth.info
            user = User.create(
              email: auth.info.email,
              password: Devise.friendly_token[0,20]
            )
            puts user.inspect
            #유저를 생성하면서, 서비스에 facebook 정보를 담아놓는다
            #Service.new랑 같은데, user_id_column에 user.id값이 들어간다.
            user.services.create(
              provider: auth.provider,
              uid: auth.uid,
              expires_at: Time.at(auth.credentials.expires_at),
              access_token: auth.credentials.token
            )
          end
            sign_in_and_redirect user
          end
      end
      # You should configure your model like this:
      # devise :omniauthable, omniauth_providers: [:twitter]

      # You should also create an action method in this controller like this:
      # def twitter
      # end

      # More info at:
      # https://github.com/plataformatec/devise#omniauth

      # GET|POST /resource/auth/twitter
      # def passthru
      #   super
      # end

      # GET|POST /users/auth/twitter/callback
      # def failure
      #   super
      # end

      # protected

      # The path used when OmniAuth fails
      # def after_omniauth_failure_path_for(scope)
      #   super(scope)
      # end
    ```

    ​

