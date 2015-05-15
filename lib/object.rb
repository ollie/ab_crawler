# Monkey-patch blank? and present? methods.
class Object
  # Am I falsy or empty?
  #
  # @return [Bool]
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  # Am I not falsy and not empty?
  #
  # @return [Bool]
  def present?
    !blank?
  end
end
