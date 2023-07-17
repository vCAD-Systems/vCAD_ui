function CheckSystem(System)
    if System == 'Copnet' then
        return 'cop'
    elseif System == 'Medicnet' then
        return 'medic'
    elseif System == 'Carnet' then
        return 'car'
    elseif System == 'Firenet' then
        return 'fd'
    else
        return false
    end
end