def inicio_dia
	"#{Time.now.in_time_zone.strftime("%Y-%m-%d")} 00:00:00"
end

def fim_dia
	"#{Time.now.in_time_zone.strftime("%Y-%m-%d")} 23:59:59"
end

def inicio_mes
	"#{Time.now.in_time_zone.beginning_of_month.strftime("%Y-%m-%d")} 00:00:00"
end

def fim_mes
	"#{Time.now.in_time_zone.end_of_month.strftime("%Y-%m-%d")} 23:59:59"
end

class String
  def vazio?
    self == "SEM_PESQUISA"
  end
  
  def deshumanize_valor
    separados = self.gsub "R$",""
    separados = separados.gsub "$",""
    separados = separados.split(",")
    separados[0] = separados[0].gsub ".",""
    separados.join(".")
  end

	def get_only_digits
		self.gsub(/[^A-Z^a-z^0-9]/, "")
	end

	def get_only_digits!
		replace self.gsub(/[^A-Z^a-z^0-9]/, "")
	end

	def get_only_numbers
		self.gsub(/[^\d]/, "")
	end

	def get_only_numbers!
		replace self.gsub(/[^\d]/, "")
	end

	def fix_date
		date = Date.strptime(self, "%d/%m/%Y")
		date.strftime("%Y-%m-%d")
	end

	def fix_date!
		if self.blank?
			replace ""
		else
			date = Date.strptime(self, "%d/%m/%Y")
			replace date.strftime("%Y-%m-%d")
		end
	end

	def fix_datetime
		date = DateTime.strptime(self, "%d/%m/%Y %H:%M:%S")
		date.strftime("%Y-%m-%d %H:%M:%S")
	end

	def fix_datetime!
		date = DateTime.strptime(self, "%d/%m/%Y %H:%M:%S")
		replace date.strftime("%Y-%m-%d %H:%M:%S")
	end
end

class Array
  def all_possibilities(from, to)
    (from..to).flat_map do |i|
      if i < size
        permutation(i).to_a 
      else
        permutation(to - i).flat_map do |e|
          (self + e).permutation.to_a
        end
      end
    end.map(&:join)
  end
end

class Date
	def fix_date
		self.strftime("%d/%m/%Y")
	end

	def fix_datetime
		self.strftime("%d/%m/%Y %H:%M:%S")
	end
end
