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