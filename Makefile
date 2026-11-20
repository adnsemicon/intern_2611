TOP ?= tb_round_robin_arbiter
TEST ?= all
ERROR_INJECT ?= 0
ifneq ($(ERROR),)
ERROR_INJECT := $(ERROR)
endif

XVLOG ?= $(shell which xvlog.bat 2>/dev/null || which xvlog 2>/dev/null || echo xvlog)
XELAB ?= $(shell which xelab.bat 2>/dev/null || which xelab 2>/dev/null || echo xelab)
XSIM  ?= $(shell which xsim.bat 2>/dev/null || which xsim 2>/dev/null || echo xsim)

FILES += -i $(CURDIR)/interface
FILES += -i $(CURDIR)/testbench
FILES += $(shell [ -d $(CURDIR)/source ] && find $(CURDIR)/source -maxdepth 1 -mindepth 1 -name "*.sv" 2>/dev/null)
FILES += $(shell [ -d $(CURDIR)/interface ] && find $(CURDIR)/interface -maxdepth 1 -mindepth 1 -name "*.sv" 2>/dev/null)
FILES += $(shell [ -d $(CURDIR)/testbench ] && find $(CURDIR)/testbench -maxdepth 1 -mindepth 1 -name "*.sv" 2>/dev/null)

.DEFAULT_GOAL = help

.PHONY: all simulate run clean help

all: simulate
simulate:
	@mkdir -p build
	@echo "*" > build/.gitignore
	@cd build && $(XVLOG) -sv $(FILES)
	@printf "%s\n" "-generic_top ERROR_INJECT=$(ERROR_INJECT)" "-s snap_$(TOP)" "-debug all" > build/xelab_args.txt
	@cd build && $(XELAB) $(TOP) -f xelab_args.txt
	@printf "%s\n" "-R" "-testplusarg TEST=$(TEST)" "snap_$(TOP)" > build/xsim_args.txt
	@cd build && $(XSIM) -f xsim_args.txt

.PHONY: clean
clean:
	@rm -rf build

.PHONY: help
help:
	@echo ""
	@echo "This repository is a SystemVerilog project for Round Robin Arbiter verification."
	@echo -e "\033[1;34m  make simulate\033[0m \033[1;35m[TOP=<TB>]\033[0m \033[1;35m[TEST=<tc1|...|tc10|all>]\033[0m \033[1;35m[ERROR_INJECT=<0|1>]\033[0m\033[55G\033[1;32m# Run simulation\033[0m"
	@echo -e "\033[1;34m  make clean\033[0m\033[55G\033[1;32m# Remove all temporary build files\033[0m"
	@echo "Please read documents/tb/round_robin_arbiter_tb.md for further details"
	@echo ""

.PHONY: depression
depression:
	@echo ""
	@printf '\033[7;31m >>> %s <<< \033[0m\n' \
		"Sinking with the ship doesn't make you a brave captain; it just makes you a drowned passenger." \
		"You are exhausting your life pouring water into a glass that has no bottom." \
		"The hardest part of a slow death is realizing you chose the executioner." \
		"Some doors aren't locked; they lead nowhere, and you're standing in the hallway freezing to death." \
		"Loyalty to a delusion is just a slow, quiet form of self-destruction." \
		"You keep bleeding on something that was never alive in the first place." \
		"The length of time you've been making a mistake doesn't turn it into a right decision." \
		"You aren't proving your strength by holding on; you're just proving how much pain you can tolerate before you break." \
		"Hope, in a dead-end situation, is just a longer path to the exact same disappointment." \
		"You are building a house out of burning wood and wondering why you keep getting burned." \
		"No amount of effort can revive a corpse; it just makes you look desperate beside it." \
		"The tragedy isn't that it failed; the tragedy is that you knew it would and stayed anyway." \
		"You're drowning in shallow water simply because you refuse to stand up." \
		"Persistence without potential is just torture with extra steps." \
		"You are throwing your future into a pit that will never fill up." \
		"Clinging to a wreck doesn't stop it from sinking—it just ensures you go down with it." \
		"The worst kind of exhaustion is fighting for something that stopped existing months ago." \
		"You're sacrificing your present for a future that was dead on arrival." \
		"Endurance is noble only when there's a finish line. Otherwise, it's just slow suicide." \
		"You didn't save it. You just delayed the inevitable and ruined yourself in the process." \
		"You are editing a rough draft for a book nobody ever plans to publish." \
		"Waiting for things to change on their own is just outsourcing your regret to the future." \
		"You have mistaken the familiarity of your cage for the comfort of a home." \
		"Some chapters don't have a climax; they just run out of ink mid-sentence." \
		"You are watering plastic plants and blaming the weather when nothing grows." \
		"The silence you are waiting to be broken is actually the final answer." \
		"You aren't being patient; you're just too terrified to look at the wreckage." \
		"Trying to earn value from people who can't afford you is a guaranteed bankruptcy." \
		"You are carrying the weight of a bridge that collapsed years ago." \
		"Nostalgia is just a polite word for refusing to accept that the good part is over." \
		"You keep knocking on a painted door and wondering why your knuckles are bleeding." \
		"The finish line was moved years ago, and nobody bothered to tell you." \
		"You are treating a permanent condition with temporary distractions." \
		"Being the last one to leave a burning building doesn't win you an award." \
		"You are starving yourself of a real life just to keep an imaginary one on life support." \
		"Most of your exhaustion comes from pretending you don't already know how this ends." \
		"You aren't misunderstood; you are just completely irrelevant to the people you're trying to impress." \
		"Forgiving someone who isn't sorry is just pre-authorizing your next wound." \
		"You are planting seeds in concrete and calling it faith." \
		"The tragedy of potential is that it decays at the exact same rate as time." \
		"You are holding onto the receipt for something that was never refundable." \
		"Surviving a storm means nothing if you choose to live underwater afterward." \
		"You are memorizing the layout of a room you were supposed to walk out of." \
		"The quietest prisons are the ones where you hold the keys from the inside." \
		"You keep trying to rewrite an ending that was already printed and distributed." \
		"Giving your best to something hollow just leaves you empty too." \
		"You are mistaking motion for progress while running on a disconnected treadmill." \
		"Nobody is coming to rescue you from a situation you actively pay rent to stay in." \
		"The light at the end of this tunnel is just an oncoming train you refuse to step aside for." \
		"You are mourning the death of something that never actually had a heartbeat." \
		"Overthinking is just rehearsing a tragedy that has already happened." \
		"You are spending gold coins to buy back pennies of attention." \
		"A sunken anchor doesn't hold the ship steady; it just makes sure it never sails again." \
		"You are archiving memories of a future that was canceled." \
		"Being reliable to the wrong things just makes you an accomplice to your own ruin." \
		"You have become a museum curator for things you should have thrown in the trash." \
		"The hardest pill to swallow is realizing you were just a background character in your own main plot." \
		"You are trying to warm your hands over the ashes of a fire that went out last winter." \
		"Closure isn't coming; you just eventually get tired of staring at the closed door." \
		"You are defending a fortress that was abandoned by everyone else months ago." \
		"Time doesn't heal everything; sometimes it just numbs you to the infection." \
		"You are translating silence into poetry because the prose is too cruel to read." \
		"Sacrificing your peace to keep the peace just leaves you at war with yourself." \
		"You aren't late to the party; the venue was demolished before you left the house." \
		"Holding a grudge is like drinking poison, except holding onto false hope tastes sweeter while it kills you." \
		"You are polishing brass on a submarine with a screen door." \
		"The echo you hear isn't someone calling back; it's just your own voice bouncing off empty walls." \
		"You are treating a dead end like a roundabout, hoping a new exit will magically appear." \
		"Eventually, even the pain gets bored of you and leaves you with nothing at all." \
		"You aren't waiting for the right moment; you're just running out the clock." \
		"You are folding laundry on a train that derailed three miles back." \
		"Accepting crumbs doesn't make you humble; it just guarantees you starve slowly." \
		"You are rehearsing apologies for crimes that were committed against you." \
		"The heaviest chains are the ones you forged yourself and painted to look like jewelry." \
		"You are checking the mailbox for a letter that was never even written." \
		"Some bridges aren't meant to be crossed; they exist solely to warn you about the drop." \
		"You are trying to build a monument out of quicksand and blaming gravity." \
		"The warmth you feel isn't comfort; it's just the friction of burning yourself out." \
		"You have spent so long surviving that you forgot how to live when the danger passed." \
		"You are auditing a bankrupt account hoping to find hidden currency." \
		"Loyalty to people who wouldn't cross a puddle for you is just volunteering for drowning." \
		"You are framing pictures of a house that burned down while you were inside it." \
		"Silence isn't always golden; sometimes it's just the sound of everyone else moving on." \
		"You are sharpening a blade to cut through fog." \
		"The role you are fighting so hard to keep was written out of the script seasons ago." \
		"You are mistaking the numbness of frostbite for finally getting used to the cold." \
		"Pouring your soul into a sieve doesn't make you generous; it just leaves you dry." \
		"You are staring at a blank canvas waiting for the paint to apply itself." \
		"Being indispensable to people who take you for granted is just a fancy way of being trapped." \
		"You are collecting trophies from battles you lost." \
		"The map you are following leads to a city that was paved over decades ago." \
		"You aren't resilient; you've just lowered your standards to survive the wreckage." \
		"Trying to fix something that wants to stay broken will only break your hands." \
		"You are paying interest on emotional debts you never actually incurred." \
		"The applause you're waiting for is coming from an empty auditorium." \
		"You are keeping a seat warm for someone who already bought a ticket elsewhere." \
		"Regret is just realizing you traded your prime years for pocket change." \
		"You are trying to navigate an ocean using a compass that only points to your own past." \
		"Some wounds don't leave scars; they just leave empty space where something used to be." \
		"You are bailing water out of a boat with a slotted spoon." \
		"The comfort zone is just a nicely decorated waiting room for missed opportunities." \
		"You are explaining colors to someone who prefers living in the dark." \
		"Every excuse you make for them is another brick in the wall around yourself." \
		"You are waiting for an invitation to a table you built with your own hands." \
		"The exhaustion isn't from the heavy lifting; it's from carrying things that aren't yours." \
		"You are rewriting history in your head just to make the present hurt a little less." \
		"A dead battery doesn't care how many times you turn the key." \
		"You are hoarding kindling in a room with no oxygen." \
		"The hardest goodbye is the one you have to say to a version of the future that never existed." \
		"You are measuring your worth on a scale that was rigged from the factory." \
		"Staying in the wrong place out of fear of being alone is just being lonely with company." \
		"You are trying to read a book with all the pages glued together." \
		"The peace you are sacrificing today will never be refunded tomorrow." \
		"You are standing in the rain holding a broken umbrella, proud that you didn't throw it away." \
		"Most of your stress comes from trying to force a square peg into a circle you drew yourself." \
		"You are treating a warning sign like a welcome mat." \
		"Eventually, you stop hurting and simply become hollow enough for the wind to pass right through." \
		"You are spending your present cleaning up messes made by people who aren't even around anymore." \
		"The tragedy of routine is that you can sleepwalk through an entire decade before waking up." \
		"You aren't stuck; you're just refusing to let go of the anchor." \
		| shuf -n 1
	@echo ""

