class CreateMPaySources < ActiveRecord::Migration
  def self.up
    create_table :m_pay_sources do |t|
      t.string :mpayid
      t.string :brand
      t.string :p_type
      t.integer :payment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :m_pay_sources
  end
end
