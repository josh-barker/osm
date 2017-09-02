#ifndef AUDIOSTACK_H
#define AUDIOSTACK_H


class AudioStack
{

public:
    struct Cell {
        float value;
        Cell * next;
        Cell * pre;
    };

protected:
    unsigned long _size = 0, sizeLimit = 0;
    Cell * firstdata, * lastdata;
    Cell * pointer;
    float halfData;
    bool halfAdded = false;


public:
    AudioStack(unsigned long size);
    void setSize(unsigned long size);
    unsigned long size();
    void add(float data);
    bool halfAdd(float data);

    void reset(void);
    bool next(void);
    float first(void);
    float current(void);
    void fill(float value);
};

#endif // AUDIOSTACK_H
