# Not a contruction kit.
# Just handy shortcuts.
# Try Ick if you want composable building blocks:
#   http://ick.rubyforge.org/inside.html
#   
module Dslicious
  
  def permutate head, body
    return( head + body ) if singles?(head, body)
    
    if single?(body)
      return inside_map( 
              permutate(body, head) 
             ) { reverse } 
    end

    head.zip(body) + head.zip(body.reverse)
  end

  def inside obj, &blok
    obj.instance_eval &blok
    obj
  end

  def inside_map enum, &blok
    enum.map { |obj|
      obj.instance_eval &blok
    }
  end

  def all? *args, &blok
    answers = args.map { |obj|
      obj.instance_eval &blok
    }
    
    all_true? answers
  end
  
  def all_true? arr
    bools = arr.map { |ans| !!ans }
    trues = bools.select { |ans| ans }
    return true if trues == bools
    false
  end

  def single? enum
    enum.size == 1
  end
  
  def not_single? enum
    enum.size != 1
  end

  def singles? *enums
    not_single = enums.detect { |enum| not_single? enum }
    return false if not_single
    true
  end
  
end # === module
