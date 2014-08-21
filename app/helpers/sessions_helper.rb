module SessionsHelper
  
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end
  
  def signed_in?
    !current_user.nil?
  end

  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def authenticate
    deny_access unless signed_in?
  end
  
  # Disallow access for signed in users
  def authenticate2
    redirect_to(root_path) if signed_in?
  end
  
  def admin_user
    (current_user.nil?) ? redirect_to(root_path) :
     (redirect_to(root_path) unless current_user.admin?)
  end
  
  def deny_access
    store_location
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to]|| default)
    clear_return_to
    sleep 2 do
      clear_content
    end
  end

  private
    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end
    
    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
    
    def store_location
      if request.post? || request.put?
	session[:return_to] = request.referer
      else
	session[:return_to] = request.fullpath
      end
    end
    
    def clear_return_to
      session[:return_to] = nil
    end
    
    def clear_content
      session[:content] = nil
    end
end
