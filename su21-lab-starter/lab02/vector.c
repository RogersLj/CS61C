/* Include the system headers we need */
#include <stdlib.h>
#include <stdio.h>

/* Include our header */
#include "vector.h"

/* Define what our struct is */
struct vector_t {
    size_t size;
    int *data;
};

/* Utility function to handle allocation failures. In this
   case we print a message and exit. */
static void allocation_failed() {
    fprintf(stderr, "Out of memory.\n");
    exit(1);
}

/* Bad example of how to create a new vector */
vector_t *bad_vector_new() {
    /* Create the vector and a pointer to it */
    vector_t *retval, v; //v is allocated at stack memory, which will be released after the function,
    retval = &v; //after the function, retval's value is not v's position anymore
    //retval指向v，但是函数结束后v就没有了，v这块区域的内存成了垃圾数据，虽然指针被传出去了，但是再次引用的时候不知道里面有什么东西，返回的指针不要指向沾栈空间里的东西

    /* Initialize attributes */
    retval->size = 1;
    retval->data = malloc(sizeof(int));
    if (retval->data == NULL) {
        allocation_failed();
    }

    retval->data[0] = 0;
    return retval;
}

/* Another suboptimal way of creating a vector */
vector_t also_bad_vector_new() {
    /* Create the vector */
    vector_t v; //v is allocated in stack memory, after function, v is gone, and the data will be exists, there will be memory leak
    //v在栈内存空间，函数结束后v没有了，随着v没有的还有v里定义的数据指针，因此在后续对返回的结构体中指针的使用，就会发生错误
    /* Initialize attributes */
    v.size = 1;
    v.data = malloc(sizeof(int));
    if (v.data == NULL) {
        allocation_failed();
    }
    v.data[0] = 0;
    return v;
}

/* Create a new vector with a size (length) of 1 and set its single component to zero... the
   right way */
/* TODO: uncomment the code that is preceded by // */
vector_t *vector_new() {
    /* Declare what this function will return */
    // vector_t *retval;
    vector_t *retval; 
    /* First, we need to allocate memory on the heap for the struct */
    // retval = /* YOUR CODE HERE */
    retval = malloc(sizeof(vector_t));
    /* Check our return value to make sure we got memory */
    // if (/* YOUR CODE HERE */) {
    //     allocation_failed();
    // }
    if (retval == NULL) {
        allocation_failed();
    }

    retval->size = 1;
    retval->data = malloc(sizeof(int));

    /* Now we need to initialize our data.
       Since retval->data should be able to dynamically grow,
       what do you need to do? */
    // retval->size = /* YOUR CODE HERE */;
    // retval->data = /* YOUR CODE HERE */;
    
    if (retval->data == NULL) {
        free(retval);
        allocation_failed();
    }
    /* Check the data attribute of our vector to make sure we got memory */
    // if (/* YOUR CODE HERE */) {
    //     free(retval);				//Why is this line necessary?
    //     allocation_failed();
    // }
    *(retval->data) = 0;
    /* Complete the initialization by setting the single component to zero */
    // /* YOUR CODE HERE */ = 0;

    /* and return... */
    return retval; /* UPDATE RETURN VALUE */
}

/* Return the value at the specified location/component "loc" of the vector */
int vector_get(vector_t *v, size_t loc) {

    /* If we are passed a NULL pointer for our vector, complain about it and exit. */
    if(v == NULL) {
        fprintf(stderr, "vector_get: passed a NULL vector.\n");
        abort();
    }

    /* If the requested location is higher than we have allocated, return 0.
     * Otherwise, return what is in the passed location.
     */
    /* YOUR CODE HERE */
    if (loc >= 0 && loc < v->size) {
        return v->data[loc];
    }

    return 0;
}

/* Free up the memory allocated for the passed vector.
   Remember, you need to free up ALL the memory that was allocated. */
void vector_delete(vector_t *v) {
    /* YOUR CODE HERE */
    free(v->data);
    free(v);
}

/* Set a value in the vector. If the extra memory allocation fails, call
   allocation_failed(). */
void vector_set(vector_t *v, size_t loc, int value) {
    /* What do you need to do if the location is greater than the size we have
     * allocated?  Remember that unset locations should contain a value of 0.
     */
    int *new_data; 
    if (loc >= v->size) {
        new_data = realloc(v->data, sizeof(int) * (loc + 1));
        if (new_data == NULL) {
            allocation_failed();
        }
        
        v->data = new_data;
        while (v->size < (loc + 1)) {
            v->size ++;
            v->data[v->size - 1] = 0;
        }

        v->data[loc] = value;
    } else {
        v->data[loc] = value;
    }
    /* YOUR CODE HERE */
}
