Feature: Private Chat
	An Attendee of a yieldto.me event should be able to chat to another Attendee of the same yieldto.me Event
	The chat messages should be visible only to each of those Attendees and not other Attendees of that Event
	Any chat messages sent when one Attendee is offline / not using yieldto.me should be accessible to that Attendee when they return online / using yieldto.me
	Messages should display consistently in the order they were sent, even when returning from an offline state
	When a new chat message is sent by one Attendee it should immediately alert the other to a new message

Scenario: Send message
	Given I am Attending an Event
		And there is at least 1 other Attendee of that Event
	When I select an Attendee to send a message to
		And I type 'Hello'
	Then the recipient Attendee should be alerted immediately there is an unread message
		And the Attendee should be able to see the 'Hello' message
		And that message should only be visible to that Attendee

Scenario: View past messages
	Given I have previously sent messages to an Attendee
	When I select that Attendee to send a message to
	Then I should see previously sent and received messages
		And those messages should be in correcct chronological order
