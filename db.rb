# frozen_string_literal: true
begin
  require_relative '.env.rb'
rescue LoadError
end

require 'sequel/core'

# Delete PHOTO_DATABASE_URL from the environment, so it isn't accidently
# passed to subprocesses.  PHOTO_DATABASE_URL may contain passwords.
DB = Sequel.connect(ENV.delete('PHOTO_DATABASE_URL') || ENV.delete('DATABASE_URL'))

# Load Sequel Database/Global extensions here
# DB.extension :date_arithmetic
DB.extension :pg_auto_parameterize if DB.adapter_scheme == :postgres && Sequel::Postgres::USES_PG
