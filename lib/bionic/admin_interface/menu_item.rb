class Bionic::AdminInterface::MenuItem
  attr_accessor :label, :url
  def initialize(label, url)
    @label = label
    @url = url
  end
end