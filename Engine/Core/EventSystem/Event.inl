#pragma once

namespace Zelo::Core::EventSystem {
template<class... ArgTypes>
ListenerID Event<ArgTypes...>::AddListener(Callback callback) {
    ListenerID listenerID = m_availableListenerID++;
    m_callbacks.emplace(listenerID, callback);
    return listenerID;
}

template<class... ArgTypes>
ListenerID Event<ArgTypes...>::operator+=(Callback callback) {
    return AddListener(callback);
}

template<class... ArgTypes>
bool Event<ArgTypes...>::RemoveListener(ListenerID listenerID) {
    return m_callbacks.erase(listenerID) != 0;
}

template<class... ArgTypes>
bool Event<ArgTypes...>::operator-=(ListenerID listenerID) {
    return RemoveListener(listenerID);
}

template<class... ArgTypes>
void Event<ArgTypes...>::RemoveAllListeners() {
    m_callbacks.clear();
}

template<class... ArgTypes>
uint64_t Event<ArgTypes...>::GetListenerCount() {
    return m_callbacks.size();
}

template<class... ArgTypes>
void Event<ArgTypes...>::Invoke(ArgTypes... args) {
    for (auto const&[key, value] : m_callbacks)
        value(args...);
}
}
