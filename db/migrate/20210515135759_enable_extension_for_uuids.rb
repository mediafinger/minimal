# frozen_string_literal: true

class EnableExtensionForUuids < ActiveRecord::Migration[6.1]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  end

  def down
    disable_extension("pgcrypto") if extension_enabled?("pgcrypto")
  end
end
