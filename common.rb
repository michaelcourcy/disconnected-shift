#We have some huge directory thus we need to move them around the 3 projects
def searchAndMoveLocally(directory_searched, proj1, proj2)
	if !Dir.exist?('./' + directory_searched ) then
		puts '' + directory_searched + ' directory missing'
		puts 'searching in ../' + proj1
		if Dir.exist?('../'+proj1+'/' + directory_searched ) then
			File.rename '../'+proj1+'/' + directory_searched , './' + directory_searched 
		else 
			puts 'searching in ../' + proj2
			if Dir.exist?('../'+proj2+'/' + directory_searched ) then 
				File.rename '../'+proj2+'/' + directory_searched , './' + directory_searched 
			else
				puts 'cannot find the ' + directory_searched + ' directory on any project cannot go any further'
				exit
			end 
		end
	end
end

#directory_searched='test'
#proj1='base_machine'
#proj2='cluster'
#searchAndMoveLocally directory_searched, proj1, proj2

