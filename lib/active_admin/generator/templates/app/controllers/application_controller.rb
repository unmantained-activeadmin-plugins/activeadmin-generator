class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale # ActiveAdmin's fault

  private

  def set_locale
    I18n.locale = I18n.default_locale
    I18n.reload!
  end
end
