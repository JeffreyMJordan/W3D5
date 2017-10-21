require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_opts = self.assoc_options[through_name]
    source_opts = through_opts.model_class.assoc_options[source_name]
    byebug
  end
end
