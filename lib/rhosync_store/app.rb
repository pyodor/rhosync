module RhosyncStore
  class App < Model
    field :name, :string
    set   :users, :string
    set   :sources, :string
    attr_reader :delegate
    validates_presence_of :name
    
    class << self
      def create(fields={})
        fields[:id] = fields[:name]
        begin
          require underscore(fields[:name])
        rescue Exception; end
        super(fields)
      end
          
      def appdir(name)
        File.join(RhosyncStore.app_directory,name)
      end
    end
    
    def can_authenticate?
      self.delegate && self.delegate.singleton_methods.include?("authenticate")
    end

    def authenticate(login, password, session)
      if self.delegate && self.delegate.authenticate(login, password, session)
        user = User.load(login) if User.is_exist?(login)
        if not user
          user = User.create(:login => login)
          self.users << user.id
        end
        return user
      end
    end
    
    def delete
      sources.members.each do |source_name|
        Source.load(source_name,{:app_id => self.name,
          :user_id => '*'}).delete
      end
      users.members.each do |user_name|
        User.load(user_name).delete
      end
      super
    end
    
    def delegate
      @delegate.nil? ? Object.const_get(camelize(self.name)) : @delegate
    end
  end
end