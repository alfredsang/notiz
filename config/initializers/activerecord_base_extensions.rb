# -*- encoding : utf-8 -*-
class ActiveRecord::Base
  # self.include_root_in_json = true

  before_create :init_token
  def init_token
    self.token = self.class.friendly_token if self.has_attribute?(:token)
  end

  def self.friendly_token(n = 15)
    SecureRandom.base64(n).tr('+/=lIO0', 'pqrsxyz')
  end

  def owned?
    User.current && User.current.id == self.user_id
  end

  def admin?
    (User.current && User.current.id == self.user_id) || self.tree.owned?
  end

  def self.acts_as_custom_options(custom_options, opts = {:as => 'options'})
    custom_options.each do |opt|
      # opt = ['background', 'String', '#ccffff']
      key, type, default = opt
      fld_name = opts[:as].to_s
      # 讀取
      case type
      when 'Hash'
        class_eval %(
          def #{key}
            (#{fld_name} && #{fld_name}[:#{key}]) || #{default || 'nil'}
          end

          def #{key}=(value)
            if self.#{fld_name}
              if self.#{fld_name}[:#{key}]
                self.#{fld_name}[:#{key}].merge!(value)
              else
                self.#{fld_name}[:#{key}] = value
              end
            else
              self.#{fld_name} = {:#{key} => value}
            end
          end
        )

      when 'Array'
        # 尚未測試
        class_eval %(
          def #{key}
            (#{fld_name} && #{fld_name}[:#{key}]) || #{default || 'nil'}
          end

          def #{key}=(value)
            (self.#{fld_name} && self.#{fld_name}[:#{key}] = value) || self.#{fld_name} = {:#{key} => value}
          end
        )

      when 'String'
        class_eval %(
          def #{key}
            (#{fld_name} && #{fld_name}[:#{key}]) || "#{default}"
          end

          def #{key}=(value)
            (self.#{fld_name} && self.#{fld_name}[:#{key}] = value || 'nil') || self.#{fld_name} = {:#{key} => value}
          end
        )

      when 'Integer'
        class_eval %(
          def #{key}
            (#{fld_name} && #{fld_name}[:#{key}]) || #{default || 'nil'}
          end

          def #{key}=(value)
            value = value ? value.to_i : nil
            (self.#{fld_name} && self.#{fld_name}[:#{key}] = value || 'nil') || self.#{fld_name} = {:#{key} => value || 'nil'}
          end
        )

      when 'Boolean'
        class_eval %(
          def #{key}
            # 存入時是字串，讀出時作 boolean 值轉換
            Boolean((#{fld_name} && #{fld_name}[:#{key}]) || #{default || 'nil'})
          end

          def #{key}=(value)
            # value = Boolean(value)
            (self.#{fld_name} && self.#{fld_name}[:#{key}] = value || 'nil') || self.#{fld_name} = {:#{key} => value || 'nil'}
          end
        )
      end
    end
  end

  #  def self.acts_as_custom_options(custome_options)
  #    custome_options.each do |k, v|
  #      # 讀取
  #      if v.is_a?(String)
  #        class_eval %(
  #          def #{k}
  #            (options && options[:#{k}]) || "#{v}"
  #          end
  #        )
  #      elsif v == nil
  #        class_eval %(
  #          def #{k}
  #            (options && options[:#{k}]) || nil
  #          end
  #        )
  #      else
  #        class_eval %(
  #          def #{k}
  #            (options && options[:#{k}]) || #{v}
  #          end
  #        )
  #      end
  #      # 存入
  #      class_eval %(
  #        def #{k}=(value)
  #          (self.options && self.options[:#{k}] = value) || self.options = {:#{k} => value}
  #        end
  #      )
  #    end
  #  end


  #  def self.acts_as_dynamic_attributes(dynamic_attrs)
  #    dynamic_attrs.each do |attr|
  #      attr_name = attr[0]
  #      attr_type = attr[1]
  #      attr_default_value = attr[2]
  #      class_eval %(

  #        def #{attr_name}
  #          if !dynamic_attribute?(:#{attr_name})
  #            add_dynamic_attribute(:#{attr_name}, '#{attr_type}')
  #            write_datt :#{attr_name}, #{attr_default_value}
  #            self.save_without_timestamping
  #          end
  #          read_datt :#{attr_name}
  #        end

  #        def #{attr_name}=(value)
  #          case '#{attr_type}'
  #          when 'string'
  #            write_datt :#{attr_name}, value
  #          when 'integer'
  #            write_datt :#{attr_name}, value.to_i
  #          end
  #        end
  #      )
  #    end
  #  end

  before_create :maintain_owner
  def maintain_owner
    if self.has_attribute?(:site_id) && !self.site_id.present?
      self.site_id = Site.current ? Site.current.id : 1
    end
    if self.has_attribute?(:user_id) && !self.user_id.present?
      self.user_id = User.current ? User.current.id : 1
    end
  end

  def save_without_timestamping
    class << self
      def record_timestamps; false; end
    end
    save
    class << self
      def record_timestamps; super ; end
    end
  end

 def self.debug(*args)
    return unless Rails.env = "development"
    title ||= ""
    logger.ap '-' * 20 + calling_method + '-' * 20
    logger.ap args
    logger.ap '-' * 100
  end

  def debug(*args)
    self.debug(args)
  end

  def Boolean(string)
    return unless string
    return true if string == true || string =~ (/(true|t|yes|y|1)$/i)
    return false if string == false || string.nil? || string =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{string}\"")
  end
end

#class ActiveRecord::Base
#  WillPaginate::ViewHelpers.pagination_options[:previous_label] = '«'
#  WillPaginate::ViewHelpers.pagination_options[:next_label] = "»"

#  def debug(*args)
#    return unless development?
#    title ||= ""
#    title += Time.now.to_s
#    logger.debug "\n\n=== in model == " + title + "=" * 50
#    logger.debug args
#    logger.debug "=== in model == " + title + "=" * 50 + "\n\n"
#  end


##  def debug(msg, title = "", options = {})
##    return unless development?
##    require 'ap'
##    url = request.env['REQUEST_URI']
##    ap("#{Time.now}: -- #{title}#{(' ')*(50 - title.length)} at: #{calling_method}, current_user: #{User.current ? User.current.id : Site.current.id}, url: #{url}")
##    ap(msg)
##  end

#  def development?;  self.class.development?; end
#  def self.development?; Rails.env == "development"; end

#  cattr_reader :per_page
#  @@per_page = 10

#  def _created_at; helpers.content_tag(:span, helpers.time_ago_in_words(created_at), :title => created_at); end
#  def _updated_at; helpers.content_tag(:span, helpers.time_ago_in_words(updated_at), :title => updated_at); end

#  def self.current_channel
#   userchannel = current_owner.is_a?(User) ? "_user_#{current_owner.id}" : nil
#    "site_#{Site.current.id}#{userchannel}"
#  end

#  def self.public_channel; "site_#{Site.current.id}"; end
#  def self.private_channel; "#{public_channel}_user_#{User.current.id}"; end

#  def self.current_owner
#    self.personal_channel? ? User.current : Site.current
#  end

#  def self.personal_channel?
#    return unless user = User.current
#    user.template == 9
#  end

#  def save_without_timestamping
#    class << self
#      def record_timestamps; false; end
#    end
#    save
#    class << self
#      def record_timestamps; super ; end
#    end
#  end

#  def owned_by_current_user?
#    return unless User.current
##    self.respond_to?("user") && self.user == User.current
#    User.current && owned_by?(User.current)
#  end

#  def owned_by?(user)
#    self.respond_to?("user") && self.user == user
#  end

#  def self.helpers
#    ActionController::Base.helpers
#  end

#  before_create :maintain_onwer
#  def maintain_onwer
#    if self.has_attribute?(:site_id)
#      #      self.site_id = eval("#{ActiveRecord::Base::get_current_site_id}")
#      self.site_id = Site.current ? Site.current.id : 1
#    end
#    return if self.class == Reserve
#    if self.has_attribute?(:user_id)
#      #      self.user_id = eval("#{ActiveRecord::Base::get_current_user_id}")
#      self.user_id = User.current.id if User.current && !self.user_id.present?
#    end
#  end

#  def helpers
#    ActionController::Base.helpers
#  end
#end

