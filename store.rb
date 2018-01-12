class CateringMatch
  class State
    def initialize
      @caterer_confirmed = false
      @customer_confirmed = false
      @version = -1
      @event_ids_to_link = []
    end

    def apply_caterer_confirmed_menu
	    @carter_confirmed = true
    end

    def apply_customer_confirmed_menu
	    @customer_confirmed = true
    end

    def complete?
	    caterer_confirmed? && customer_confirmed?
    end

    def apply(*events)
	    events.each do |event|
	    case event
	    when CatererConfirmedMenu then
		    apply_caterer_confirmed_menu
	    when CustomerConfirmedMenu then
		    apply_customer_confirmed_menu
	    end
	    @event_ids_to_link << event.id
	    end
    end

    def load(stream_name, event_store:)
	    events =
		    event_store.read_stream_events_forward(stream_name)
	    events.each do |event|
	    end
	    @version = events.size - 1
	    @event_ids_to_link = []
	    self
    end

    def store(stream_name, event_store:)
	    event_store.link_to_stream(
		    @event_ids_to_link,
		    stream_name: stream_name,
		    expected_version: @version
	    )
	    @version += @event_ids_to_link.size
	    @event_ids_to_link = []
    end
  end

    private_constant :State

    def initialize(command_bus:, event_store:)
	    @command_bus = command_bus
	    @event_store = event_store
    end

    def call(event)
	    order_id = event.data(:order_id)
	    stream_name = "CateringMatch$#{order_id}"

	    state = Steate.new
	    state.load(stream_name, event_store: @event_store)
	    state.apply(event)
	    state.store(stream_name, event_store: @event_store)

	    command_bus.(ConfirmOrder.new(data: {
		    order_id: oreder_id
	    })) if state.complete?
    end
end





  end

end

