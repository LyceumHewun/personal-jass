// 计算两点之间距离
function CalcDistance takes real x1, real y1, real x2, real y2 returns real
    return SquareRoot(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))
endfunction

// 计算两单位之间距离
function CalcDistanceByUnit takes unit u1, unit u2 returns real
    return CalcDistance(GetUnitX(u1), GetUnitY(u1), GetUnitX(u2), GetUnitY(u2))
endfunction

function CalcDistanceByLoc takes location l1, location l2 returns real
    return CalcDistance(GetLocationX(l1), GetLocationY(l1), GetLocationX(l2), GetLocationY(l2))
endfunction

// 计算两点之间的角度
function CalcAngle takes real x1, real y1, real x2, real y2 returns real
    local real dx
    local real dy
    local real angle

    set dx = x2 - x1
    set dy = y2 - y1
    set angle = bj_RADTODEG * Atan2(dy, dx)

    return angle
endfunction

// 计算两单位之间的角度
function CalcAngleByUnit takes unit u1, unit u2 returns real
    return CalcAngle(GetUnitX(u1), GetUnitY(u1), GetUnitX(u2), GetUnitY(u2))
endfunction

function CalcAngleByLoc takes location l1, location l2 returns real
    return CalcAngle(GetLocationX(l1), GetLocationY(l1), GetLocationX(l2), GetLocationY(l2))
endfunction

// 生成一个位置
// 根据给定的坐标、距离和角度生成一个位置
function GenerateLoc takes real x, real y, real distance, real angle returns location
    local real dx
    local real dy
    local real radian

    // TODO 缓存
    set radian = angle * bj_DEGTORAD
    set dx = x + distance * Cos(radian)
    set dy = y + distance * Sin(radian)

    return Location(dx, dy)
endfunction

function GenerateLocByUnit takes unit u, real distance, real angle returns location
    return GenerateLoc(GetUnitX(u), GetUnitY(u), distance, angle)
endfunction

function GenerateLocByLoc takes location l, real distance, real angle returns location
    return GenerateLoc(GetLocationX(l), GetLocationY(l), distance, angle)
endfunction

function IsOdd takes integer i returns boolean
    return i % 2 == 1
endfunction
