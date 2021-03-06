require 'dl_validator/version'
require 'config/dl_config'
require  'extensions/drivers_license_invalid_validator' if defined?(Rails)

module DlValidator
  def self.invalid?(dl_number, dl_state)
    # Stop and return true if either dl_number or dl_state are nil
    return true if dl_number.nil? or dl_state.nil?

    # Downcase and remove non-word characters
    dl_number = dl_number.to_s.upcase.gsub(/(\W|_)*/, '')
    dl_state  = dl_state.to_s.upcase.gsub(/(\W|\d|_)*/, '')

    # Stop here and return true if the state does not exist
    return true if !DlConfig::STATES.include?(dl_state) and !DlConfig::STATES.values.include?(dl_state)

    # Find the state abbreviation key we need to access our regex hash.
    key = get_abbreviation_key(dl_state)

    # Regular expression match to validate the drivers license is invalid or not
    return false if DlConfig::STATES_REGEX[key].match(dl_number)
    true
  end

  # This is moved out into a method to make unit testing easier.
  def self.get_abbreviation_key(dl_state)
    # If the dl_state is greater than 2 then it is a full state name and we need to find the corresponding abbreviation for that state.
    key = ''
    if dl_state.length > 2
      DlConfig::STATES.each do |k, v|
        key = k if v == dl_state
      end
    else
      key = dl_state # The dl_state is already an abbreviated state
    end
    key
  end

  # Inverse of invalid?
  def self.valid?(dl_number, dl_state)
    !invalid?(dl_number, dl_state)
  end
end
