# coding: utf-8

module EH
  module Trans
    @@items = {
      "de" => {},
      "en" => {},
    }
    @@skills = {
      "de" => {},
      "en" => {},
    }
    # menus are hardcoded anyway, so we dont parse anything
    @@menu = {
      "de" => {
        :menu => "Menü",
        :titlescreen_title => "Ewige Hoffnung",
        :newgame => "Neues Spiel",
        :loadgame => "Spiel laden",
        :options => "Optionen",
        :update => "Update",
        :items => "Gegenstände",
        :equipment => "Ausrüstung",
        :skills => "Fertigkeiten",
        :save => "Speichern",
        :load => "Laden",
        :language => "Sprache",
        :options_details => "Details",
        :volume => "Lautstärke",
        :lang_english => "Englisch",
        :lang_german => "Deutsch",
        :restart_warning => "Das Spiel muss neugestartet werden, um alle Einstellungen zu übernehmen.",
      },
      "en" => {
        :menu => "Menu",
        :titlescreen_title => "Ewige Hoffnung",
        :newgame => "New Game",
        :loadgame => "Load Game",
        :options => "Options",
        :update => "Update",
        :items => "Items",
        :equipment => "Equipment",
        :skills => "Skills",
        :save => "Save",
        :load => "Load",
        :language => "Language",
        :options_details => "Details",
        :volume => "Volume",
        :lang_english => "English",
        :lang_german => "German",
        :restart_warning => "The game must be restarted to apply all settings.",
      },
    }
    def self.parse_items
      begin
        file = File.open("def/#{EH.config[:language]}/items.trans", "r")
        block = false
        name = desc = ""
        item = nil
        file.each_line { |line|
          line.gsub!("\n", "")
          if line.start_with?("#") or line.length == 0
            if line == "#EOF"
              break
            end
            next
          end
          if line[0] == "{"
            block = true
          end
          if line[0] == "}"
            block = false
            @@items[EH.config[:language]].store(item.name, name)
            @@items[EH.config[:language]].store("#{item.name}_desc", desc)
            next
          end
          if block
            if line.start_with?("name")
              line.gsub!(/name *= */, "")
              name = line.gsub("\"", "")
            elsif line.start_with?("desc")
              line.gsub!(/desc *= */, "")
              desc = line.gsub("\"", "")
            end
          else
            item = EH::Game.find_item(line)
          end
        }
        file.close
      rescue Errno::ENOENT
        puts("FATAL: No item translations for selected language (#{EH.config[:language]}) found!")
        if EH.config[:language] != "de"
          EH.config[:language] = "de"
          puts("INFO: Changed language to 'de' (German), try restarting")
          EH.exit(1)
        else
          puts("INFO: Even the default language is not working, the install seems to be broken.\nTry redownloading the application.")
          EH.exit(1)
        end
      end
    end
    def self.parse_skills
      begin
        file = File.open("def/#{EH.config[:language]}/skills.trans", "r")
        block = false
        name = desc = ""
        skill = nil
        file.each_line { |line|
          line.gsub!("\n", "")
          if line.start_with?("#") or line.length == 0
            if line == "#EOF"
              break
            end
            next
          end
          if line[0] == "{"
            block = true
          end
          if line[0] == "}"
            block = false
            @@skills[EH.config[:language]].store(skill.name, name)
            @@skills[EH.config[:language]].store("#{skill.name}_desc", desc)
            next
          end
          if block
            if line.start_with?("name")
              line.gsub!(/name *= */, "")
              name = line.gsub("\"", "")
            elsif line.start_with?("desc")
              line.gsub!(/desc *= */, "")
              desc = line.gsub("\"", "")
            end
          else
            skill = EH::Game.find_skill(line)
          end
        }
        file.close
      rescue Errno::ENOENT
        puts("FATAL: No skill translations for selected language (#{EH.config[:language]}) found!")
        if EH.config[:language] != "de"
          EH.config[:language] = "de"
          puts("INFO: Changed language to 'de' (German), try restarting")
          EH.exit(1)
        else
          puts("INFO: Even the default language is not working, the install seems to be broken.\nTry redownloading the application.")
          EH.exit(1)
        end
      end
    end
    def self.item(sym)
      return @@items[EH.config[:language]][sym]
    end
    def self.skill(sym)
      return @@skills[EH.config[:language]][sym]
    end
    def self.menu(sym)
      return @@menu[EH.config[:language]][sym]
    end
  end
end
