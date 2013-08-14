#works with level 9 , 8 , 7 , 6 , 5 , 4 , 3 , 2 , ( 1 is only warrior.walk!)
class Player
  MAX_HEALTH = 20 #constant represent the full health of warrior
  DAMAGE_IMPACT = 3 #the damage the enemy does us
  NUMBER_OF_HITS_SUPPOURT = 4 # How many hits can support
  MIN_HEALTH = ((DAMAGE_IMPACT * NUMBER_OF_HITS_SUPPOURT) - 1)#constant represent the minimun health of warrior for rest
  OUR_DIRECTIONS = [:backward , :forward] #The array represent the queue for search in both directions
  def play_turn(warrior)
    start_assault(warrior , OUR_DIRECTIONS.first)
    update_health(warrior)
  end #end my turn
  #The principal function
  def start_assault(warrior , direction)
    if direction == nil && @DIRECTION_OF_STAIRS != nil
       direction = @DIRECTION_OF_STAIRS
    end
    if !OUR_DIRECTIONS.empty? && (warrior.feel(direction).wall? || warrior.feel(direction).stairs?)
        OUR_DIRECTIONS.delete_at(0)#delete the current direction of the array
      if warrior.feel(direction).stairs? && @DIRECTION_OF_STAIRS == nil #verfy if warrior are in the stairs and we don't have this direction
         @DIRECTION_OF_STAIRS = direction #store the direction of the stairs
      end
      return 0 #end of turn beacause no has more directions or the warrior are in wall or stairs
    end
    #warrior start to play
    if warrior.feel(direction).enemy? #the enemy is in front
      if has_enoungth_health(warrior) #check if warrior has health for attack
         warrior.attack!(direction)
      else
         warrior.walk!(run_away(direction)) # Get away
      end
    elsif need_rest(warrior) #if has very damage 
      warrior.rest!
    elsif warrior.feel(direction).captive? # warrior is a hero, save everyone =)
      warrior.rescue!(direction)
    elsif !has_enoungth_health(warrior) #check if warrior has health for walk
      warrior.walk!(run_away(direction)) #Get away
    else
      atack_distance_enemies(warrior,direction) #check enemies like wizards or archers, atack or keep moving
    end
  end
  # When the warrior lost health we can call this function 
  # and Run to opposite direction
  def run_away(current_direction)
     return current_direction == :backward ? :forward : :backward #return oposite direction
  end
  # When the health is lesser than max health of warrior and 
  # Warrior has't a damage, so warrior rest, the warrior have priority attack to the enemy =)
  def need_rest(warrior)
    begin
      return warrior.health < MAX_HEALTH && !has_damage(warrior)
    rescue 
      return false
    end
  end
  #when we have the ability look and shoot this function return if warrior has a enemy nearest
  # and shoot or keep walk
  def atack_distance_enemies(warrior , direction)
    begin
          if(has_enemies_near(warrior , direction))
             warrior.shoot!(direction)
          else
             warrior.walk!(direction)
          end
    rescue 
      warrior.walk!(direction)
    end
  end
  # In every turn update health(maybe the warrior has a damage)
  def update_health(warrior)
    begin
      @health = warrior.health
    rescue
      @health = MAX_HEALTH
    end
  end
  #Check if the enemy is near and shoot, if not keep moving
  def has_enemies_near(warrior , direction)
    return warrior.look(direction).any?{ |space| space.enemy? } && !warrior.look(direction).any?{ |space| space.captive? }
  end
  #Check if the warrior has the min health for keep fight, if not maybe need to rest
  def has_enoungth_health(warrior)
    begin
      return warrior.health >= MIN_HEALTH
    rescue
      return true
    end
  end
  #Check if the warrior health is lesser than the final turn
  def has_damage(warrior)
    return warrior.health < @health
  end
end #end of player class
