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
