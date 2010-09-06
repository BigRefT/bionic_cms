class Encrypter
  def initialize(attrs_to_manage)
    @attrs_to_manage = attrs_to_manage
  end

  def before_save(model)
    @attrs_to_manage.each do |field|
      next if model[field].empty_or_nil?
      model[field] = Sentry::SymmetricSentry.encrypt_to_base64(model[field],"k3.33_1$")
    end
  end

  def after_save(model)
    @attrs_to_manage.each do |field|
      next if model[field].empty_or_nil?
      model[field] = Sentry::SymmetricSentry.decrypt_from_base64(model[field],"k3.33_1$")
    end
  end

  alias_method :after_find, :after_save
end

class ActiveRecord::Base
  def self.encrypt(*attr_names)
    encrypter = Encrypter.new(attr_names)

    before_save encrypter
    after_save encrypter
    after_find encrypter

    define_method(:after_find) {}
  end
  
  def sentry_decrypt(value)
    return if value.empty_or_nil?
    Sentry::SymmetricSentry.decrypt_from_base64(value,"k3.33_1$")
  end

  def sentry_encrypt(value)
    return if value.empty_or_nil?
    Sentry::SymmetricSentry.encrypt_to_base64(value,"k3.33_1$")
  end
end