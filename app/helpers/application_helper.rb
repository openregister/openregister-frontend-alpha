module ApplicationHelper
  def prepare_register_name(register_name)
    unless register_name.nil?
      register_name.gsub('-', ' ').split.map(&:capitalize) * ' '
    end
  end

  def get_register(register_name)
    OpenRegister.register(register_name.downcase, :beta)
  end

  def crest_class_name(authority)
    case authority
    when "home-office"
      "logo-with-crest crest-ho"
    when "ministry-of-defence"
      "logo-with-crest crest-mod"
    when "hm-revenue-customs"
      "logo-with-crest crest-hmrc"
    when "welsh-government"
      "logo-with-crest crest-wales"
    when "department-for-business-innovation-and-skills"
      "logo-with-crest crest-bis"
    when "the-office-of-the-leader-of-the-house-of-commons"
      "logo-with-crest crest-portcullis"
    when "office-of-the-advocate-general-for-scotland"
      "logo-with-crest crest-so"
    when "uk-atomic-energy-authority"
      "logo-with-crest crest-ukaea"
    when "nhs", "government-digital-service", "scottish-government"
      " "
    else
      "logo-with-crest crest-org"
    end
  end
end
