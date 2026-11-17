# Added by aalfath/spree-railway-template.
# `railway:prepare` runs `db:prepare` (schema + seed on an empty database,
# migrations on an existing one) and then, while no admin account exists,
# prints Spree's one-time first-run setup link to the deploy logs.
namespace :railway do
  desc 'Prepare the database and print the first-run setup link if needed'
  task prepare: 'db:prepare' do
    Rake::Task['environment'].invoke
    admin_class = Spree.admin_user_class
    next if admin_class.blank? || admin_class.exists?

    store = Spree::Store.default
    next if store.nil? || !store.persisted?

    store.regenerate_setup_token if store.setup_token.blank?
    puts <<~MSG

      ==> Spree has no admin account yet. Open this link to create it
          (the link works once; it stops working as soon as an admin exists):

          #{store.setup_url}

    MSG
  end
end
