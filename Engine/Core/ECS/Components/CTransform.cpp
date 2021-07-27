

#include <UI/Widgets/Texts/Text.h>
#include <UI/Widgets/Drags/DragMultipleFloats.h>

#include "Core/ECS/Components/CTransform.h"

OvCore::ECS::Components::CTransform::CTransform(ECS::Actor &owner, OvMaths::FVector3 localPosition,
                                                OvMaths::FQuaternion localRotation, OvMaths::FVector3 localScale) :
        AComponent(owner) {
    m_transform.GenerateMatrices(localPosition, localRotation, localScale);
}

std::string OvCore::ECS::Components::CTransform::GetName() {
    return "Transform";
}

void OvCore::ECS::Components::CTransform::SetParent(CTransform &parent) {
    m_transform.SetParent(parent.GetFTransform());
}

bool OvCore::ECS::Components::CTransform::RemoveParent() {
    return m_transform.RemoveParent();
}

bool OvCore::ECS::Components::CTransform::HasParent() const {
    return m_transform.HasParent();
}

void OvCore::ECS::Components::CTransform::SetLocalPosition(OvMaths::FVector3 newPosition) {
    m_transform.SetLocalPosition(newPosition);
}

void OvCore::ECS::Components::CTransform::SetLocalRotation(OvMaths::FQuaternion newRotation) {
    m_transform.SetLocalRotation(newRotation);
}

void OvCore::ECS::Components::CTransform::SetLocalScale(OvMaths::FVector3 newScale) {
    m_transform.SetLocalScale(newScale);
}

void OvCore::ECS::Components::CTransform::TranslateLocal(const OvMaths::FVector3 &translation) {
    m_transform.TranslateLocal(translation);
}

void OvCore::ECS::Components::CTransform::RotateLocal(const OvMaths::FQuaternion &rotation) {
    m_transform.RotateLocal(rotation);
}

void OvCore::ECS::Components::CTransform::ScaleLocal(const OvMaths::FVector3 &scale) {
    m_transform.ScaleLocal(scale);
}

const OvMaths::FVector3 &OvCore::ECS::Components::CTransform::GetLocalPosition() const {
    return m_transform.GetLocalPosition();
}

const OvMaths::FQuaternion &OvCore::ECS::Components::CTransform::GetLocalRotation() const {
    return m_transform.GetLocalRotation();
}

const OvMaths::FVector3 &OvCore::ECS::Components::CTransform::GetLocalScale() const {
    return m_transform.GetLocalScale();
}

const OvMaths::FVector3 &OvCore::ECS::Components::CTransform::GetWorldPosition() const {
    return m_transform.GetWorldPosition();
}

const OvMaths::FQuaternion &OvCore::ECS::Components::CTransform::GetWorldRotation() const {
    return m_transform.GetWorldRotation();
}

const OvMaths::FVector3 &OvCore::ECS::Components::CTransform::GetWorldScale() const {
    return m_transform.GetWorldScale();
}

const OvMaths::FMatrix4 &OvCore::ECS::Components::CTransform::GetLocalMatrix() const {
    return m_transform.GetLocalMatrix();
}

const OvMaths::FMatrix4 &OvCore::ECS::Components::CTransform::GetWorldMatrix() const {
    return m_transform.GetWorldMatrix();
}

OvMaths::FTransform &OvCore::ECS::Components::CTransform::GetFTransform() {
    return m_transform;
}

OvMaths::FVector3 OvCore::ECS::Components::CTransform::GetWorldForward() const {
    return m_transform.GetWorldForward();
}

OvMaths::FVector3 OvCore::ECS::Components::CTransform::GetWorldUp() const {
    return m_transform.GetWorldUp();
}

OvMaths::FVector3 OvCore::ECS::Components::CTransform::GetWorldRight() const {
    return m_transform.GetWorldRight();
}

OvMaths::FVector3 OvCore::ECS::Components::CTransform::GetLocalForward() const {
    return m_transform.GetLocalForward();
}

OvMaths::FVector3 OvCore::ECS::Components::CTransform::GetLocalUp() const {
    return m_transform.GetLocalUp();
}

OvMaths::FVector3 OvCore::ECS::Components::CTransform::GetLocalRight() const {
    return m_transform.GetLocalRight();
}

void OvCore::ECS::Components::CTransform::OnSerialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) {
    OvCore::Helpers::Serializer::SerializeVec3(doc, node, "position", GetLocalPosition());
    OvCore::Helpers::Serializer::SerializeQuat(doc, node, "rotation", GetLocalRotation());
    OvCore::Helpers::Serializer::SerializeVec3(doc, node, "scale", GetLocalScale());
}

void OvCore::ECS::Components::CTransform::OnDeserialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) {
    m_transform.GenerateMatrices
            (
                    OvCore::Helpers::Serializer::DeserializeVec3(doc, node, "position"),
                    OvCore::Helpers::Serializer::DeserializeQuat(doc, node, "rotation"),
                    OvCore::Helpers::Serializer::DeserializeVec3(doc, node, "scale")
            );
}

void OvCore::ECS::Components::CTransform::OnInspector(OvUI::Internal::WidgetContainer &root) {
    auto getRotation = [this] {
        return OvMaths::FQuaternion::EulerAngles(GetLocalRotation());
    };

    auto setRotation = [this](OvMaths::FVector3 result) {
        SetLocalRotation(OvMaths::FQuaternion(result));
    };

    OvCore::Helpers::GUIDrawer::DrawVec3(root, "Position", std::bind(&CTransform::GetLocalPosition, this),
                                         std::bind(&CTransform::SetLocalPosition, this, std::placeholders::_1), 0.05f);
    OvCore::Helpers::GUIDrawer::DrawVec3(root, "Rotation", getRotation, setRotation, 0.05f);
    OvCore::Helpers::GUIDrawer::DrawVec3(root, "Scale", std::bind(&CTransform::GetLocalScale, this),
                                         std::bind(&CTransform::SetLocalScale, this, std::placeholders::_1), 0.05f,
                                         0.0001f);
}
