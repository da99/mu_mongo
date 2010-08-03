
class Path_Map

  attr_reader :prefix, :control, :url_aliases
  def initialize prefix, &blok
    @control = nil
    @prefix = prefix
    @url_aliases = []
    instance_eval(&blok) if block_given?
  end

  def to obj_class
    @control = obj_class
  end

  def path *args
    suffix, action, verbs = args
    action              ||= suffix.split('/').compact.last.gsub('-', '_')
    verbs                 = [verbs || 'GET'].flatten.compact.uniq
    filename              = suffix.split('/').last
    full_path             = if filename && filename['.']
                              File.join(prefix, suffix)
                            else
                              File.join(prefix, suffix, '/')
                            end
    @url_aliases << [full_path, control, action, verbs]
  end

  def map new_prefix, &blok
    @url_aliases += begin
                      new_map      = self.class.new(File.join(prefix, new_prefix))
                      orig_control = control
                      new_map.instance_eval {
                        to orig_control
                        instance_eval(&blok)
                        self.url_aliases
                      }
                    end
  end
  
  def top_slash &blok
    old_prefix = prefix
    @prefix = '/'
    instance_eval &blok
    @prefix = old_prefix
  end
  
end # === class
