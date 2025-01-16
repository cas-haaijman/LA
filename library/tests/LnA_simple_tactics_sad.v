Require Import LnA.LnA.
Require Import Strings.String.
Open Scope string_scope.

Parameter a b c: Prop.
Parameter X Y Z: Set.
Parameter x x1 x2 x3: X.
Parameter y: Y.
Parameter z: Z.

Section test_con_i.
    Check "sad_test_con_i".
    Lemma sad_test_con_i : True.
        Fail con_i.
    Abort.
End test_con_i.
Section test_dis_i.
    Check "sad_test_dis_i1".
    Lemma sad_test_dis_i1 : True.
        Fail dis_i1.
    Abort.
    Check "sad_test_dis_i2".
    Lemma sad_test_dis_i2 : True.
        Fail dis_i2.
    Abort.
End test_dis_i.
Section test_dis_e.
    Check "sad_test_dis_e_H1_exists".
    Lemma sad_test_dis_e_H1_exists (H1: True) : a.
        Fail dis_e (a \/ b) H1 H2.
    Abort.
    Check "sad_test_dis_e_H2_exists".
    Lemma sad_test_dis_e_H2_exists (H2: True) : a.
        Fail dis_e (a \/ b) H1 H2.
    Abort.
    Check "sad_test_dis_e_not_disjunction".
    Lemma sad_test_dis_e_not_disjunction : a.
        Fail dis_e True H1 H2.
    Abort.
End test_dis_e.
Section test_imp_i.
    Check "sad_test_imp_i_not_imp_generic".
    Lemma sad_test_imp_i_not_imp_generic : True.
        Fail imp_i H.
        Show.
    Abort.
    Check "sad_test_imp_i_not_imp_forall".
    Lemma sad_test_imp_i_not_imp_forall : forall x:X, x=x.
        Fail imp_i H.
        Show.
    Abort.
End test_imp_i.
Section test_all_i.
    Check "sad_test_all_i_xNew_exists".
    Lemma sad_test_all_i_xNew_exists (xNew: X) : forall xQuant:X, xQuant = xQuant.
        Fail all_i xNew.
        Show.
    Abort.
    Check "sad_test_all_i_not_forall_generic".
    Lemma sad_test_all_i_not_forall_generic : True.
        Fail all_i xNew.
        Show.
    Abort.
    Check "sad_test_all_i_not_forall_imp".
    Lemma sad_test_all_i_not_forall_imp : a -> b.
        Fail all_i xNew.
        Show.
    Abort.
End test_all_i.
Section test_all_e.
    Check "sad_test_all_e_wrong_instance".
    Lemma sad_test_all_e : x = x.
        Fail all_e (forall xQuant:X, True) x.
    Abort.
    Check "sad_test_all_e_not_forall".
    Lemma sad_test_all_e_not_forall : x = x.
        Fail all_e True x.
    Abort.
End test_all_e.
Section test_eqv_i.
    Check "sad_test_eqv_i".
    Lemma sad_test_eqv_i : True.
        Fail eqv_i.
    Abort.
End test_eqv_i.
Section test_eqv_e1.
    Check "sad_test_eqv_e1".
    Lemma sad_test_eqv_e1 : True.
        Fail eqv_e1.
    Abort.
End test_eqv_e1.
Section test_eqv_e2.
    Check "sad_test_eqv_e2".
    Lemma sad_test_eqv_e2 : True.
        Fail eqv_e2.
    Abort.
End test_eqv_e2.
Section test_iff_i.
    Check "sad_test_iff_i".
    Lemma sad_test_iff_i : True.
        Fail iff_i H1 H2.
    Abort.
End test_iff_i.
Section test_LEM.
    Check "sad_test_LEM".
    Lemma sad_test_LEM : True.
        Fail LEM.
        Show.
    Abort.
End test_LEM.
Section test_exi_i.
    Check "sad_test_exi_i_wrong_type".
    Lemma sad_test_exi_i : exists xQuant:X, xQuant=xQuant.
        Fail exi_i y.
    Abort.
    Check "sad_test_exi_i_not_exists".
    Lemma sad_test_exi_i_not_exists : True.
        Fail exi_i x.
    Abort.
End test_exi_i.
Section test_exi_e.
    Check "sad_test_exi_e_H_exists".
    Lemma sad_test_exi_e_H_exists (H: True) : x1=x1.
        Fail exi_e (exists xQuant:X, xQuant=xQuant) xNew H.
    Abort.
    Check "sad_test_exi_e_xNew_exists".
    Lemma sad_test_exi_e_H_exists (xNew: X) : x1=x1.
        Fail exi_e (exists xQuant:X, xQuant=xQuant) xNew H.
    Abort.
    Check "sad_test_exi_e_not_exists".
    Lemma sad_test_exi_e_not_exists : x1=x1.
        Fail exi_e True xNew H.
    Abort.
End test_exi_e.
Section test_neg_i.
    Check "sad_test_neg_i_not_neg".
    Lemma sad_test_neg_i : True.
        Fail neg_i b H.
    Abort.
End test_neg_i.