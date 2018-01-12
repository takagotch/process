TestEvent = Class.new(RubyEventStore::Event)

specify 'link events' do
	client = RubyEventStore::Client.new(repository:
					    InMemoryRepository.new)
	first_event = TestEvent.new
	second_event = TextEvent.new
	
	client.append_to_stream(
		[first_event, second_event],
		stream_name 'stream'
	)
	client.link_to_stream(
		[first_event.event_id, second_event.event_id],
		stream_name: 'flow',
		ecpected_version: -1
	)
	client.link_to_stream(
		[first_event.event_id],
		stream_name: 'cars',
	)

	expect(client.read_stream_events_forward('flow')).to eq([first_event, second_event])
	expect(client.read_stream_events_forward('cars')).to eq([first_event])
end


