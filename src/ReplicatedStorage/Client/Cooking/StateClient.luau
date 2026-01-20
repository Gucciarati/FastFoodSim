export type CookingProcessData = {
    ProcessType: string,
    MachineId: string,
    IngredientId: string,
}

local function RequestCookingStart(ProcessData: CookingProcessData)
    local EndTime = StartCookingProcessRF:InvokeServer(ProcessData)
    local TimeTillEnd = EndTime - workspace:GetServerTimeNow()
    --Play necessary twens and animations
end

local function RegisterCookingInteraction(IngredientId: string)