require_relative 'DatabaseWorker'

if __FILE__ == $PROGRAM_NAME
	@database_workers = []
	db_worker = DatabaseWorker.new()
	@database_workers << db_worker
end


