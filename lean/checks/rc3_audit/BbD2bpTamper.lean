import GenChi4

-- NEGATIVE CONTROLS (bb): each must FAIL (2 errors expected); both statements are FALSE, so these are genuine rejects.
-- T1: root number of chi_{-4} claimed -1.
example : DirichletCharacter.rootNumber DBN.Gen.chiM4 = -1 := DBN.Gen.rootNumber_chiM4
-- T2: the Gauss sum of chi_{-4} claimed -2i.
example : gaussSum DBN.Gen.chiM4 ZMod.stdAddChar = -2 * Complex.I := DBN.Gen.gaussSum_chiM4
