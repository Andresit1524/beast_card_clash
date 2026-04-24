from colorama import Fore, Style, Back
from enum import Enum, auto
import random as r
import os

# --- Classes ---


class Element(Enum):
    """Elementos de las cartas"""

    AIR = auto()
    EARTH = auto()
    ENERGY = auto()
    FIRE = auto()
    WATER = auto()


class Card:
    """Representa una carta de batalla"""

    def __init__(self, element: Element, power: int = 1):
        self.element = element
        self.power = power

        if self.power > 10 or self.power < 1:
            print_color("[Error] Carta fuera de rango", Fore.RED)

    def __repr__(self):
        return f"Card({self.element.name} - {self.power})"


class Player:
    """Representa a un jugador en el duelo"""

    def __init__(self, name: str, health: int = 100):
        self.name = name
        self.health = health
        self.deck = []
        self.current_card = None

    def __repr__(self):
        return f"Player({self.name} - {self.health})"

    def take_damage(self, amount: int = 1):
        self.health = max(0, self.health - amount)
        if self.health <= 0:
            print_color(f"{self.name} has dead!", Fore.RED)
            game_over(self, players)

    def add_card(self, card: Card):
        self.deck.append(card)

    def remove_card(self, card: Card):
        self.deck.remove(card)

    def create_deck(self):
        for i in range(PLAYER_CARDS):
            current_card = Card(r.choice(list(Element)), r.randint(1, 10))

            self.deck.append(current_card)


# --- Game logic ---


def print_color(text: str, color: int = Fore.WHITE):
    print(color + text + Style.RESET_ALL)


def make_players():
    players = [
        Player(f"Player {i}", MAX_HEALTH)
        for i in range(1, r.randint(2, MAX_PLAYERS) + 1)
    ]

    for player in players:
        player.create_deck()

    return players


def compare_elements(card1: Card, card2: Card):
    # Same element
    if card1.element == card2.element:
        if card1.power > card2.power:
            return 1
        elif card1.power < card2.power:
            return -1
        else:
            return 0

    # Rest of combination
    match card1.element:
        case Element.AIR:
            if (card2.element == Element.EARTH) or (card2.element == Element.WATER):
                return 1
            elif (card2.element == Element.ENERGY) or (card2.element == Element.FIRE):
                return -1
        case Element.EARTH:
            if (card2.element == Element.ENERGY) or (card2.element == Element.FIRE):
                return 1
            elif (card2.element == Element.AIR) or (card2.element == Element.WATER):
                return -1
        case Element.ENERGY:
            if (card2.element == Element.AIR) or (card2.element == Element.WATER):
                return 1
            elif (card2.element == Element.EARTH) or (card2.element == Element.FIRE):
                return -1
        case Element.FIRE:
            if (card2.element == Element.AIR) or (card2.element == Element.ENERGY):
                return 1
            elif (card2.element == Element.EARTH) or (card2.element == Element.WATER):
                return -1
        case Element.WATER:
            if (card2.element == Element.EARTH) or (card2.element == Element.FIRE):
                return 1
            elif (card2.element == Element.AIR) or (card2.element == Element.ENERGY):
                return -1


def card_battle(players: list[Player]):
    battles_list = set()

    for player1 in players:
        for player2 in players:
            if player1 == player2:
                continue

            if player1.current_card is None or player2.current_card is None:
                continue

            # Avoid duplicates
            current_battle = frozenset([player1, player2])
            if current_battle in battles_list:
                continue

            battles_list.add(current_battle)

            print(f"{player1.name} vs {player2.name}")
            match compare_elements(player1.current_card, player2.current_card):
                case 1:
                    print_color(f"    {player1.name} wins!", Fore.GREEN)
                    player2.take_damage()
                case -1:
                    print_color(f"    {player2.name} wins!", Fore.GREEN)
                    player1.take_damage()
                case 0:
                    print_color("    Draw!", Fore.YELLOW)
                    continue


def game_over(player: Player, players: list[Player]):
    if player in players:
        players.remove(player)

    return players


# Game constants
PLAYER_CARDS = 7
MAX_HEALTH = 5
MAX_PLAYERS = 4

# Game variables
current_round = 0
current_player_rock = None

# --- Game ---

os.system("cls")
print_color("BCC Console Demo", Fore.GREEN)

players = make_players()
r.shuffle(players)

print_color(f"There are {len(players)} players", Fore.GREEN)

# Game loop
while True:
    print_color(f"\n---------- [Round {current_round}] ----------", Fore.BLUE)

    for player in players:
        # Elección del jugador
        current_player_rock = r.choice(list(Element))
        current_card = r.choice(player.deck)
        print_color(f"{player.name:<10} rock: {current_player_rock.name:<10}")

        # Juego de la carta
        if current_card.element == current_player_rock:
            print_color(
                f"{player.name:<10} turn: {str(current_card):<22} | (HP: {player.health:<3}) ({len(player.deck) - 1} cards left)",
                Fore.CYAN,
            )

            player.current_card = current_card
            player.remove_card(current_card)
        else:
            player.current_card = None
            print_color(
                f"{player.name:<10} turn: {str(current_card):<22} | (HP: {player.health:<3}) (Not allowed by the rock)",
                Fore.RED,
            )

    card_battle(players)

    # Kills player when ends with no cards
    for player in players[:]:
        if len(player.deck) <= 0:
            player.take_damage(MAX_HEALTH)

    # End of game
    if len(players) <= 1:
        print_color("---------- [Game over] ----------", Fore.MAGENTA)
        if len(players) < 1:
            print_color("No players left!", Fore.RED)
            break

        print_color(f"{players[0].name} wins!", Fore.MAGENTA)
        break

    print_color("Turn end", Fore.YELLOW)

    current_round += 1
