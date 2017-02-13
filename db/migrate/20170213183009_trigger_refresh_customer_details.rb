class TriggerRefreshCustomerDetails < ActiveRecord::Migration[5.0]
  def up
    execute %{
      CREATE OR REPLACE FUNCTION
        refresh_customer_details()
        RETURNS TRIGGER LANGUAGE PLPGSQL
      AS $$
      BEGIN
        REFRESH MATERIALIZED VIEW customer_details;
        RETURN NULL;
      END $$;
    }
    %w(customers
      customers_shipping_addresses
      customers_billing_addresses
      addresses).each do |table|
        execute %{
          CREATE TRIGGER refresh_customer_details
          AFTER
            INSERT OR
            UPDATE OR
            DELETE
          ON #{table}
            FOR EACH STATEMENT
              EXECUTE PROCEDURE
                refresh_customer_details()
        }
      end
  end

  def down

  end
end
