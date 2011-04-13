# module Devise
#   module Orm
#     module MongoMapper
#       module Hook
#         def devise_modules_hook!
#           extend Schema
#           include Compatibility
#           yield
#           return unless Devise.apply_schema
#           devise_modules.each { |m| send(m) if respond_to?(m, true) }
#         end
#       end
# 
#       module Schema
#         include Devise::Schema
# 
#         # Tell how to apply schema methods
#         def apply_devise_schema(name, type, options={})
#           # type = Time if type == DateTime
#           key name, type, options
#         end
#       end
# 
#       module Compatibility
#         # extend ActiveSupport::Concern
# 
#         module ClassMethods
#           def find_for_authentication(conditions)
#             # find(:first, :conditions => conditions)
#             first(conditions)
#           end
# 
#           # Find an initialize a record setting an error if it can't be found.
#           def find_or_initialize_with_error_by(attribute, value, error=:invalid) #:nodoc:
#             if value.present?
#               conditions = { attribute => value }
#               record = first(conditions) # find(:first, :conditions => conditions)
#             end
# 
#             unless record
#               record = new
#               if value.present?
#                 record.send(:"#{attribute}=", value)
#               else
#                 error = :blank
#               end
#               record.errors.add(attribute, error)
#             end
# 
#             record
#           end
# 
#           # Recreate the user based on the stored cookie
#           def serialize_from_cookie(id, remember_token)
#             conditions = { :id => id, :remember_token => remember_token }
# 
#             record = first(conditions) # find(:first, :conditions => conditions)
# 
#             record if record && !record.remember_expired?
#           end
# 
#         end
#       end # Compatibility
# 
#     end # MongoMapper
#   end # Orm
# end # Devise
# 
# class Warden::SessionSerializer
#   def deserialize(keys)
#     klass, id = keys
#     klass.constantize.find(id)
#   end
# end
# 
# MongoMapper::Document.append_extensions(Devise::Models)
# MongoMapper::Document.append_extensions(Devise::Orm::MongoMapper::Hook)

module Devise
  module Orm
    module MongoMapper
      module InstanceMethods
        def save(options={})
          if options == false
            super(:validate => false)
          else
            super
          end
        end
      end

      def self.included_modules_hook(klass)
        klass.send :extend,  self
        klass.send :include, InstanceMethods
        yield

        klass.devise_modules.each do |mod|
          klass.send(mod) if klass.respond_to?(mod)
        end
      end
      
      def find(*args)
        case args.first
        when :first, :all
          send(args.shift, *args)
        else
          super
        end
      end
      
      include Devise::Schema
      

      # Tell how to apply schema methods. This automatically converts DateTime
      # to Time, since MongoMapper does not recognize the former.
      def apply_schema(name, type, options={})
        return unless Devise.apply_schema
        type = Time if type == DateTime
        key name, type, options
      end
    end
  end
end

if MongoMapper::Version >= "0.8.0"
  puts "FRIST IF"
  MongoMapper::Plugins::Document::ClassMethods.send(:include, Devise::Models)
  # MongoMapper::Plugins::EmbeddedDocument::ClassMethods.send(:include, Devise::Models)
  puts "THIS IS AFTER CACHING"
  # MongoMapper::Plugins::Caching.send(:include, Devise::Models)
else
  puts "ELSE"
  MongoMapper::Document::ClassMethods.send(:include, Devise::Models)
  MongoMapper::EmbeddedDocument::ClassMethods.send(:include, Devise::Models)
end