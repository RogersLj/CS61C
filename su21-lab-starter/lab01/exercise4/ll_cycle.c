#include <stddef.h>
#include "ll_cycle.h"

int ll_has_cycle(node *head) {
    /* TODO: Implement ll_has_cycle */
    if (!head || !head->next) return 0;

    node* f = head;
    node* s = head;

    while (f->next && f->next->next)
    {
        f = f->next->next;
        s = s->next;
        if (s == f) return 1;
    }
    
    return 0;
}
