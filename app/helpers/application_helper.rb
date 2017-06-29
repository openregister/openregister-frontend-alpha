module ApplicationHelper
  def prepare_register_name(register_name)
    unless register_name.nil?
      register_name.gsub('-', ' ').split.map(&:capitalize) * ' '
    end
  end

  def get_register(register_name)
    OpenRegister.register(register_name.downcase, :beta)
  end
end
