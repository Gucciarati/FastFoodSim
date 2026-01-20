local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils             = ReplicatedStorage:WaitForChild('Utils')
local Config            = ReplicatedStorage:WaitForChild('Config')

local CreateRegistry    = require(Utils.CreateRegistry)

local CashBundlesFolder = Config.CashBundles

local LooseBill         = require(CashBundlesFolder.LooseBill)
local SmallPile         = require(CashBundlesFolder.SmallPile)
local MoneyStash        = require(CashBundlesFolder.MoneyStash)
local MoneyStack        = require(CashBundlesFolder.MoneyStack)
local CashCache         = require(CashBundlesFolder.CashCache)
local MoneyBag          = require(CashBundlesFolder.MoneyBag)
local GoldenChest       = require(CashBundlesFolder.GoldenChest)
local BankVault         = require(CashBundlesFolder.BankVault)


local CashBundleRegistry = CreateRegistry.CreateDictRegistry()

local function addCashBundlesToRegistry(bundles)
	for bundleName, bundleData in bundles do
		CashBundleRegistry.register(bundleName, bundleData)
	end
end

addCashBundlesToRegistry(LooseBill)
addCashBundlesToRegistry(SmallPile)
addCashBundlesToRegistry(MoneyStash)
addCashBundlesToRegistry(MoneyStack)
addCashBundlesToRegistry(CashCache)
addCashBundlesToRegistry(MoneyBag)
addCashBundlesToRegistry(GoldenChest)
addCashBundlesToRegistry(BankVault)

return CashBundleRegistry
