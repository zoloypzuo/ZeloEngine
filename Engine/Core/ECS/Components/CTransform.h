

#pragma once

#include "Core/ECS/Components/AComponent.h"

#include <Maths/FTransform.h>
#include <Maths/FVector3.h>
#include <Maths/FQuaternion.h>

#include "AComponent.h"

namespace Zelo::Core::ECS { class Actor; }

namespace Zelo::Core::ECS::Components {

class CTransform : public AComponent {
public:

    CTransform(ECS::Actor &owner, struct OvMaths::FVector3 localPosition = OvMaths::FVector3(0.0f, 0.0f, 0.0f),
               OvMaths::FQuaternion localRotation = OvMaths::FQuaternion::Identity,
               struct OvMaths::FVector3 localScale = OvMaths::FVector3(1.0f, 1.0f, 1.0f));


    std::string GetName() override;


    void SetParent(CTransform &parent);


    bool RemoveParent();


    bool HasParent() const;


    void SetLocalPosition(struct OvMaths::FVector3 newPosition);


    void SetLocalRotation(OvMaths::FQuaternion newRotation);


    void SetLocalScale(struct OvMaths::FVector3 newScale);


    void TranslateLocal(const struct OvMaths::FVector3 &translation);


    void RotateLocal(const OvMaths::FQuaternion &rotation);


    void ScaleLocal(const struct OvMaths::FVector3 &scale);


    const OvMaths::FVector3 &GetLocalPosition() const;


    const OvMaths::FQuaternion &GetLocalRotation() const;


    const OvMaths::FVector3 &GetLocalScale() const;


    const OvMaths::FVector3 &GetWorldPosition() const;


    const OvMaths::FQuaternion &GetWorldRotation() const;


    const OvMaths::FVector3 &GetWorldScale() const;


    const OvMaths::FMatrix4 &GetLocalMatrix() const;


    const OvMaths::FMatrix4 &GetWorldMatrix() const;


    OvMaths::FTransform &GetFTransform();


    OvMaths::FVector3 GetWorldForward() const;


    OvMaths::FVector3 GetWorldUp() const;


    OvMaths::FVector3 GetWorldRight() const;


    OvMaths::FVector3 GetLocalForward() const;


    OvMaths::FVector3 GetLocalUp() const;


    OvMaths::FVector3 GetLocalRight() const;


    virtual void OnSerialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) override;


    virtual void OnDeserialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) override;


    virtual void OnInspector(OvUI::Internal::WidgetContainer &root) override;

private:
    OvMaths::FTransform m_transform;
};
}