defmodule Hearthstone.ArchetypesTest do
  use ExUnit.Case, async: true

  describe "guess_archetypes" do
    @should_guess [
      {"Fel DH","AAECAea5AwS1yQON9wOHiwSXoAQN2cYD3dMDx90Dyt0D8+MDkOQDlegDwvEDifcDjPcDmfkDg58Etp8EAA=="},
      {"Deathrattle DH","AAECAea5AwK/7QOHiwQO2cYDyd0Dyt0D8+MDkOQDu+0DvO0D/e0DqO8Di/cDqZEEtpIE+JQEyZ8EAA=="},
      {"Ramp Druid","AAECAZICBImLBLigBKWtBISwBA3lugPougPvugObzgPw1AOJ4AOK4AOk4QPR4QOM5AOP5AOvgATPrAQA"},
      {"Ramp Druid","AAECAZICBuy6A+66A7WKBImLBKWtBISwBAzougObzgPw1AOJ4AOK4AOk4QPR4QOP5AOvgASJnwSunwTPrAQA"},
      {"Beast Druid","AAECAZICAtmfBJSlBA6bzgO50gOV4AOM5AOt7APJ9QPs9QOB9wOE9wOsgASvgASwgATnpAS4vgQA"},
      {"Taunt Druid","AAECAZICAortA7uKBA7XvgPevgO50gOM5AO57AOI9APJ9QP09gOB9wOsgASHnwTWoAThpASXpQQA"},
      {"Celestial Druid","AAECAZICBrrQA+TuA7+ABLWKBImLBKWtBAzmugPougObzgPw1AOJ4AOK4AOV4AOk4QPA7AOvgASwgATanwQA"},
      {"Face Hunter","AAECAR8E4c4Dj+MD3OoD5e8DDd6+A9zMA6LOA4LQA7nSA4vVA4biA/DsA/f4A8X7A8OABLugBOGkBAA="},
      {"Quest Hunter","AAECAR8C5e8D/fgDDrnQA43kA9vtA/f4A6iBBKuNBKmfBKqfBOOfBOSfBLugBL+sBMGsBJmtBAA="},
      {"Mozaki Mage","AAECAf0EApLLA/T8Aw7BuAPHzgPNzgP30QOF5APU6gPQ7APR7AOn9wOu9wOy9wOogQSKjQT8ngQA"},
      {"Wildfire Mage","AAECAf0EBtjsA53uA6CKBKiKBJiNBMagBAz73QPT7APW7AOn9wOx9wOSgQSTgQSUgQSfkgShkgTonwT7ogQA"},
      {"Wildfire Mage","AAECAf0EAtjsA6CKBA73uAPgzAObzQPHzgP7zgP73QPU6gPT7APW7AOogQSYjgSfkgShkgT8ngQA"},
      {"Libram Paladin","AAECAZ8FBoTBA/voA5HsA9n5A7+ABOCLBAz9uAPquQPruQPsuQPKwQOVzQPA0QPM6wPw9gON+APhpAT5pAQA"},
      {"Buff Paladin","AAECAZ8FBvy4A/voA5HsA8f5A7+ABOCLBAzevgPKwQO/0QOL1QPM6wPw9gON+AO2gATJoAThpAT0pAT5pAQA"},
      {"Shadow Priest","AAECAa0GBp/rA+fwA7v3A7+ABK2KBIujBAzevgObzQPXzgO70QOL1QPK4wP09gOI9wOj9wOt9wONgQThpAQA"},
      {"Miracle Priest","AAECAa0GAtTtA7WKBA6TugOWugOnywPezAPi3gP73wPK4QOY6wOZ6wOH9wOtigSEowSJowSKowQA"},
      {"Miracle Priest","AAECAa0GAof3A7uKBA6TugOWugObugOnywO00QPi3gP73wPK4QP74wOY6wOtigSFnwSEowSJowQA"},
      {"Quest Priest","AAECAa0GCMi+A9TtA6bvA932A4f3A8z5A+iLBNasBAuTugP+0QPi3gOW6AOa6wPN8gPJ+QOtigSFnwSIowTUrAQA"},
      {"Big Priest","AAECAa0GCsi+A5vYA+rhA6bvA4f3A6mBBOiLBKeNBIWfBNasBAqTugPi3gP73wP44wOa6wOe6wPM+QOMgQSIowSKowQA"},
      {"Dragon Priest","AAECAa0GA8i+A8ugBISwBA2TugPezAPi3gP73wOb6wOe6wOG9wOH9wOtigSFnwSKowTIrATUrAQA"},
    ]
  end

end
